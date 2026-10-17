import 'dart:typed_data';
import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/data_source/simulator_device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/repository/device_repository_impl.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/usecase/request_animation_use_case.dart';

import '../../../../helpers/device_matchers.dart';

class _FakeDataSource extends Fake implements DeviceBleDataSource {
  _FakeDataSource({this.scanError, this.timeSync = false});

  final Object? scanError;
  final bool timeSync;
  final sent = <DeviceCommandModel>[];
  @override
  bool get supportsTimeSync => timeSync;
  @override
  bool get supportsStatedPreference => false;
  @override
  Future<LearningExplanationModel?> readExplanation() async {
    final error = scanError;
    if (error != null) throw error;
    return LearningExplanationModel.decode(Uint8List.fromList(
        [1, 20, 0, 0, 1, 4, 0, 0, 154, 0, 128, 0, 128, 0, 0, 0, 128, 0, 0, 0]));
  }

  final _statuses = StreamController<DeviceStatusModel>.broadcast();

  @override
  Stream<DeviceStatusModel> get statuses => _statuses.stream;

  @override
  Future<List<String>> scan() async {
    final error = scanError;
    if (error != null) throw error;
    return const [];
  }

  @override
  Future<DeviceStatusModel> connect(String deviceId) async =>
      _stateChange(DeviceProtocol.animationIdle);

  @override
  Future<DeviceStatusModel> send(DeviceCommandModel command) async {
    sent.add(command);
    return DeviceStatusModel(
      kind: DeviceProtocol.statusResult,
      requestId: sent.length,
      resultCode: DeviceProtocol.resultOk,
      animationCode: DeviceProtocol.animationIdle,
      sequence: 0,
    );
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> close() => _statuses.close();

  void emit(DeviceStatusModel status) => _statuses.add(status);

  void emitError(Object error) => _statuses.addError(error);
}

DeviceStatusModel _stateChange(int animationCode) => DeviceStatusModel(
      kind: DeviceProtocol.statusStateChange,
      requestId: 0,
      resultCode: DeviceProtocol.resultOk,
      animationCode: animationCode,
      sequence: 3,
    );

void main() {
  test('connect syncs phone time immediately and every six hours', () async {
    final dataSource = _FakeDataSource(timeSync: true);
    final local = DateTime.parse('2026-10-17T08:30:00+07:00');
    final repository = DeviceRepositoryImpl(
      dataSource,
      now: () => local,
      timezoneOffset: () => const Duration(hours: 7),
      syncInterval: const Duration(milliseconds: 10),
    );
    addTearDown(repository.onClose);
    await repository.connect('xuna');
    expect(dataSource.sent, hasLength(1));
    expect(dataSource.sent.single.opcode, DeviceProtocol.opcodeTimeSync);
    expect(dataSource.sent.single.utcSeconds,
        local.toUtc().millisecondsSinceEpoch ~/ 1000);
    expect(dataSource.sent.single.timezoneOffsetMinutes, 420);
    await Future<void>.delayed(const Duration(milliseconds: 25));
    expect(dataSource.sent.length, greaterThanOrEqualTo(2));
    await repository.disconnect();
    final count = dataSource.sent.length;
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(dataSource.sent, hasLength(count));
  });

  test('explanation repository maps fixture and translates malformed transport',
      () async {
    final repository = DeviceRepositoryImpl(_FakeDataSource());
    addTearDown(repository.onClose);
    expect((await repository.readExplanation())!.reason, LearningReason.told);
    final malformed = DeviceRepositoryImpl(
        _FakeDataSource(scanError: const FormatException('bad explanation')));
    addTearDown(malformed.onClose);
    await expectLater(malformed.readExplanation(),
        throwsA(isDeviceException(DeviceExceptionKind.invalidResponse)));
  });

  test(
      'simulator requires connection; happy expires and reconnect reads current state',
      () async {
    final repository = DeviceRepositoryImpl(SimulatorDeviceBleDataSource(
      happyDuration: const Duration(milliseconds: 20),
    ));
    addTearDown(repository.onClose);
    await expectLater(
      repository.requestAnimation(AnimationState.happy),
      throwsA(isDeviceException(DeviceExceptionKind.notConnected)),
    );
    expect(await repository.scan(), [SimulatorDeviceBleDataSource.deviceId]);
    await repository.connect(SimulatorDeviceBleDataSource.deviceId);
    final requestAnimation = RequestAnimationUseCase(repository);
    expect(
      (await requestAnimation.execute(AnimationState.happy)).animation,
      AnimationState.happy,
    );
    await repository.disconnect();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      (await repository.connect(SimulatorDeviceBleDataSource.deviceId))
          .animation,
      AnimationState.idle,
    );
    expect(
      (await requestAnimation.execute(AnimationState.idle)).sequence,
      2,
    );
  });

  test('translates transport and platform errors into DeviceException',
      () async {
    final cases = <(Object, DeviceExceptionKind)>[
      (TimeoutException('scan'), DeviceExceptionKind.timeout),
      (const FormatException('bad frame'), DeviceExceptionKind.invalidResponse),
      (StateError('platform'), DeviceExceptionKind.communicationFailed),
      (
        const DeviceException(DeviceExceptionKind.bluetoothOff),
        DeviceExceptionKind.bluetoothOff,
      ),
    ];
    for (final (error, kind) in cases) {
      final repository =
          DeviceRepositoryImpl(_FakeDataSource(scanError: error));
      addTearDown(repository.onClose);
      await expectLater(repository.scan(), throwsA(isDeviceException(kind)));
    }
  });

  test('status stream maps models and translates errors', () async {
    final dataSource = _FakeDataSource();
    final repository = DeviceRepositoryImpl(dataSource);
    addTearDown(repository.onClose);
    final events = <Object>[];
    final subscription =
        repository.watchStatus().listen(events.add, onError: events.add);
    addTearDown(subscription.cancel);

    dataSource.emit(_stateChange(DeviceProtocol.animationHappy));
    dataSource.emitError(const FormatException('bad frame'));
    dataSource.emit(_stateChange(9));
    await Future<void>.delayed(Duration.zero);

    expect(events, hasLength(3));
    expect(
      events[0],
      const DeviceStatus(animation: AnimationState.happy, sequence: 3),
    );
    expect(events[1], isDeviceException(DeviceExceptionKind.invalidResponse));
    expect(events[2], isDeviceException(DeviceExceptionKind.invalidResponse));
  });
}
