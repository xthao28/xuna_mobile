import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'dart:async';

import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/codec/protocol_codec.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/data/model/life_summary_model.dart';
import 'package:xuna_mobile/features/device/data/model/memory_episode_model.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

/// Development fake of the BLE transport, selected with
/// `--dart-define=XUNA_SIMULATOR=true`.
///
/// It mirrors the firmware's bounded preference rule (MVP-local M05) so the
/// app can be exercised without a board. It validates neither firmware
/// behavior, BLE nor persistence, and its state lives only for the app
/// session. Do not add learning rules here (AGENTS §6); conformance with the
/// firmware is checked by golden vectors in session S20.
class SimulatorDeviceBleDataSource implements DeviceBleDataSource {
  // UI fake has no v3 evidence projection; never fabricate a learned reason.
  @override
  Future<LearningExplanationModel?> readExplanation() async {
    _requireConnection();
    return null;
  }

  @override
  bool get supportsStatedPreference => true;
  @override
  // The simulator has no wall-clock/day-part model, so it must not claim the
  // production capability or keep a six-hour transport timer alive in UI tests.
  bool get supportsTimeSync => false;
  SimulatorDeviceBleDataSource({
    this.happyDuration = const Duration(milliseconds: 2400),
  });

  static const deviceId = 'XUNA simulator';

  /// Approval/rejection counts are halved before reaching this bound.
  static const _countLimit = 1000;

  final Duration happyDuration;
  final _statuses = StreamController<DeviceStatusModel>.broadcast();
  final _memories = <MemoryEpisodeModel>[];

  /// Counts indexed by `[contextCode][actionCode]` (idle or happy).
  final _positive = List.generate(2, (_) => [0, 0]);
  final _negative = List.generate(2, (_) => [0, 0]);
  Timer? _expiry;
  bool _connected = false;
  bool _feedbackUsed = true;
  int _requestId = 0;
  int _decision = 0;
  int _events = 0;
  int _contextCode = DeviceProtocol.contextQuiet;
  int _actionCode = DeviceProtocol.animationIdle;
  int _animationCode = DeviceProtocol.animationIdle;
  int _sequence = 0;

  @override
  Stream<DeviceStatusModel> get statuses => _statuses.stream;

  @override
  Future<List<String>> scan() async => [deviceId];

  @override
  Future<DeviceStatusModel> connect(String deviceId) async {
    if (deviceId != SimulatorDeviceBleDataSource.deviceId) {
      throw const DeviceException(DeviceExceptionKind.deviceNotFound);
    }
    _connected = true;
    _requestId = 0;
    _decision = 0;
    _feedbackUsed = true;
    return _status(DeviceProtocol.statusSnapshot);
  }

  @override
  Future<DeviceStatusModel> send(DeviceCommandModel command) async {
    _requireConnection();
    final requestId = ++_requestId;
    // Round-trip through the codec: same validation as the real transport.
    final (_, decoded) =
        ProtocolCodec.decodeCommand(ProtocolCodec.encode(requestId, command));
    switch (decoded.opcode) {
      case DeviceProtocol.opcodeAnimation:
        _decision = 0;
        _feedbackUsed = true;
        _applyAnimation(decoded.argument);
      case DeviceProtocol.opcodeSuggest:
        _contextCode = decoded.argument;
        _actionCode = _choose(_contextCode);
        _applyAnimation(_actionCode);
        _decision = requestId;
        _feedbackUsed = false;
      case DeviceProtocol.opcodeFeedback:
        if (_feedbackUsed || decoded.target != _decision) {
          throw const DeviceException(
            DeviceExceptionKind.rejected,
            resultCode: DeviceProtocol.resultInvalidArgument,
          );
        }
        _recordFeedback(
          approved: decoded.argument == 1,
          sourceCode: decoded.source,
        );
      case DeviceProtocol.opcodeForget:
        _forget();
      case DeviceProtocol.opcodeStatedPreference:
        _events++;
      case DeviceProtocol.opcodeTimeSync:
        break;
    }
    return _status(DeviceProtocol.statusResult, requestId: requestId);
  }

  @override
  Future<LifeSummaryModel> readLife() async {
    _requireConnection();
    return LifeSummaryModel(
      contextCode: _contextCode,
      actionCode: _actionCode,
      activeSeconds: 0,
      events: _events,
      decisionId: _decision,
      quietChoiceCode: _choose(DeviceProtocol.contextQuiet),
      playChoiceCode: _choose(DeviceProtocol.contextPlay),
      canFeedback: !_feedbackUsed,
      memoryCount: _events.clamp(0, DeviceProtocol.maxMemoryEpisodes),
    );
  }

  @override
  Future<List<MemoryEpisodeModel>> readMemories() async {
    _requireConnection();
    return List.unmodifiable(_memories);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _decision = 0;
    _feedbackUsed = true;
  }

  @override
  Future<void> close() async {
    _expiry?.cancel();
    await _statuses.close();
  }

  void _requireConnection() {
    if (!_connected) {
      throw const DeviceException(DeviceExceptionKind.notConnected);
    }
  }

  DeviceStatusModel _status(int kind, {int requestId = 0}) => DeviceStatusModel(
        kind: kind,
        requestId: requestId,
        resultCode: DeviceProtocol.resultOk,
        animationCode: _animationCode,
        sequence: _sequence,
      );

  /// Happy and curious return to idle after [happyDuration], as on the board.
  void _applyAnimation(int animationCode) {
    _expiry?.cancel();
    if (_animationCode != animationCode) {
      _animationCode = animationCode;
      _sequence = (_sequence + 1) & 0xffffffff;
    }
    _statuses.add(_status(DeviceProtocol.statusStateChange));
    if (animationCode == DeviceProtocol.animationHappy ||
        animationCode == DeviceProtocol.animationCurious) {
      _expiry = Timer(
        happyDuration,
        () => _applyAnimation(DeviceProtocol.animationIdle),
      );
    }
  }

  /// Higher Beta(1,1) approval estimate wins; a tie keeps idle.
  int _choose(int contextCode) {
    final positive = _positive[contextCode];
    final negative = _negative[contextCode];
    final happyWins = (positive[1] + 1) * (positive[0] + negative[0] + 2) >
        (positive[0] + 1) * (positive[1] + negative[1] + 2);
    return happyWins
        ? DeviceProtocol.animationHappy
        : DeviceProtocol.animationIdle;
  }

  void _recordFeedback({required bool approved, required int sourceCode}) {
    final positive = _positive[_contextCode];
    final negative = _negative[_contextCode];
    final action = _actionCode;
    if ((approved ? positive[action] : negative[action]) >= _countLimit) {
      positive[action] = (positive[action] + 1) ~/ 2;
      negative[action] = (negative[action] + 1) ~/ 2;
    }
    if (approved) {
      positive[action]++;
    } else {
      negative[action]++;
    }
    _events++;
    _memories.add(MemoryEpisodeModel(
      contextCode: _contextCode,
      actionCode: action,
      approved: approved,
      sourceCode: sourceCode,
    ));
    if (_memories.length > DeviceProtocol.maxMemoryEpisodes) {
      _memories.removeAt(0);
    }
    _feedbackUsed = true;
  }

  void _forget() {
    for (final row in [..._positive, ..._negative]) {
      row.fillRange(0, 2, 0);
    }
    _memories.clear();
    _events = 0;
    _decision = 0;
    _feedbackUsed = true;
  }
}
