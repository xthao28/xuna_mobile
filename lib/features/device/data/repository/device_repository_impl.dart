import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/data/mapper/learning_explanation_mapper.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/mapper/device_codes.dart';
import 'package:xuna_mobile/features/device/data/mapper/device_status_mapper.dart';
import 'package:xuna_mobile/features/device/data/mapper/life_summary_mapper.dart';
import 'package:xuna_mobile/features/device/data/mapper/memory_episode_mapper.dart';
import 'package:xuna_mobile/features/device/data/mapper/pet_identity_mapper.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_bind_proof.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class DeviceRepositoryImpl extends BaseRepository implements DeviceRepository {
  DeviceRepositoryImpl(
    this._dataSource, {
    DeviceStatusMapper? statusMapper,
    LifeSummaryMapper? lifeMapper,
    MemoryEpisodeMapper? memoryMapper,
    DateTime Function()? now,
    Duration Function()? timezoneOffset,
    Duration syncInterval = const Duration(hours: 6),
  })  : _statusMapper = statusMapper ?? DeviceStatusMapper(),
        _lifeMapper = lifeMapper ?? LifeSummaryMapper(),
        _memoryMapper = memoryMapper ?? MemoryEpisodeMapper(),
        _now = now ?? DateTime.now,
        _timezoneOffset =
            timezoneOffset ?? (() => DateTime.now().timeZoneOffset),
        _syncInterval = syncInterval;

  final DeviceBleDataSource _dataSource;
  final DeviceStatusMapper _statusMapper;
  final LifeSummaryMapper _lifeMapper;
  final MemoryEpisodeMapper _memoryMapper;
  final DateTime Function() _now;
  final Duration Function() _timezoneOffset;
  final Duration _syncInterval;
  Timer? _syncTimer;
  @override
  bool get supportsStatedPreference => _dataSource.supportsStatedPreference;
  @override
  bool get supportsTimeSync => _dataSource.supportsTimeSync;
  @override
  bool get supportsIdentity => _dataSource.supportsIdentity;
  @override
  bool get supportsDeviceProof => _dataSource.supportsDeviceProof;

  @override
  Future<DeviceBindProof> requestBindProof(List<int> nonce) => _guard(() async {
        if (!_dataSource.supportsDeviceProof) {
          throw const DeviceException(DeviceExceptionKind.unsupportedDevice);
        }
        final model =
            await _dataSource.requestBindProof(Uint8List.fromList(nonce));
        return switch (model.status) {
          DeviceProtocol.proofStatusOk => DeviceBindProof(
              generation: model.generation,
              publicKey: List.unmodifiable(model.publicKey),
              signature: List.unmodifiable(model.signature),
            ),
          DeviceProtocol.proofStatusUnsupportedPurpose ||
          DeviceProtocol.proofStatusNotReady =>
            throw const DeviceException(DeviceExceptionKind.proofUnavailable),
          _ => throw DeviceException(
              DeviceExceptionKind.proofFailed,
              resultCode: model.status,
            ),
        };
      });

  @override
  Future<PetIdentity?> readIdentity() => _guard(() async {
        final model = await _dataSource.readIdentity();
        return model == null || !model.ready
            ? null
            : PetIdentityMapper().mapToEntity(model);
      });

  @override
  Future<LearningExplanation?> readExplanation() => _guard(() async {
        final model = await _dataSource.readExplanation();
        return model == null
            ? null
            : LearningExplanationMapper().mapToEntity(model);
      });

  @override
  Stream<DeviceStatus> watchStatus() => _dataSource.statuses.transform(
        StreamTransformer.fromHandlers(
          handleData: (model, sink) {
            try {
              sink.add(_statusMapper.mapToEntity(model));
            } catch (error, stackTrace) {
              sink.addError(_translate(error), stackTrace);
            }
          },
          handleError: (error, stackTrace, sink) =>
              sink.addError(_translate(error), stackTrace),
        ),
      );

  @override
  Future<List<String>> scan() => _guard(_dataSource.scan);

  @override
  Future<DeviceStatus> connect(String deviceId) => _guard(() async {
        final connected = await _dataSource.connect(deviceId);
        if (!_dataSource.supportsTimeSync) {
          return _statusMapper.mapToEntity(connected);
        }
        final synced = await _syncTime();
        _syncTimer?.cancel();
        _syncTimer = Timer.periodic(_syncInterval, (_) {
          unawaited(_syncTime().then<void>(
            (_) {},
            onError: (Object _, StackTrace __) {},
          ));
        });
        return _statusMapper.mapToEntity(synced);
      });

  @override
  Future<DeviceStatus> requestAnimation(AnimationState animation) =>
      _send(DeviceCommandModel.animation(DeviceCodes.animation(animation)));

  @override
  Future<DeviceStatus> suggest(InteractionContext context) =>
      _send(DeviceCommandModel.suggest(DeviceCodes.context(context)));

  @override
  Future<void> sendFeedback({
    required bool approved,
    required bool fromText,
    required int decisionId,
  }) =>
      _send(DeviceCommandModel.feedback(
        approved: approved,
        source: DeviceCodes.feedbackSource(fromText: fromText),
        target: decisionId,
      ));

  @override
  Future<LifeSummary> readLife() =>
      _guard(() async => _lifeMapper.mapToEntity(await _dataSource.readLife()));

  @override
  Future<List<MemoryEpisode>> readMemories() => _guard(() async =>
      _memoryMapper.mapToListEntity(await _dataSource.readMemories()));

  @override
  Future<void> forget() => _send(const DeviceCommandModel.forget());
  @override
  Future<void> statePreference(
      {required bool likes,
      required int contextKey,
      required AnimationState action}) {
    if (!supportsStatedPreference) {
      throw const DeviceException(DeviceExceptionKind.unsupportedDevice);
    }
    return _send(DeviceCommandModel.statedPreference(
        likes: likes,
        contextKey: contextKey,
        action: DeviceCodes.animation(action)));
  }

  @override
  Future<void> disconnect() {
    _syncTimer?.cancel();
    _syncTimer = null;
    return _guard(_dataSource.disconnect);
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    unawaited(_dataSource.close());
    super.onClose();
  }

  Future<DeviceStatus> _send(DeviceCommandModel command) => _guard(
      () async => _statusMapper.mapToEntity(await _dataSource.send(command)));

  Future<DeviceStatusModel> _syncTime() {
    final now = _now();
    return _dataSource.send(DeviceCommandModel.timeSync(
      utcSeconds: now.toUtc().millisecondsSinceEpoch ~/ 1000,
      timezoneOffsetMinutes: _timezoneOffset().inMinutes,
    ));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(_translate(error), stackTrace);
    }
  }

  /// Maps every transport or platform error to a [DeviceException].
  static DeviceException _translate(Object error) => switch (error) {
        DeviceException() => error,
        TimeoutException() =>
          DeviceException(DeviceExceptionKind.timeout, rootException: error),
        FormatException() => DeviceException(
            DeviceExceptionKind.invalidResponse,
            rootException: error,
          ),
        _ => DeviceException(
            DeviceExceptionKind.communicationFailed,
            rootException: error,
          ),
      };
}
