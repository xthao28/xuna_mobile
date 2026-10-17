import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/data_source/simulator_device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/model/device_proof_model.dart';
import 'package:xuna_mobile/features/device/data/repository/device_repository_impl.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

import '../../../../helpers/device_matchers.dart';

class _ProofSource extends Fake implements DeviceBleDataSource {
  _ProofSource({this.status = 2, this.supported = true, this.error});

  final int status;
  final bool supported;
  final Object? error;
  final nonces = <Uint8List>[];

  @override
  bool get supportsDeviceProof => supported;

  @override
  Future<DeviceProofModel> requestBindProof(Uint8List nonce) async {
    nonces.add(nonce);
    final failure = error;
    if (failure != null) throw failure;
    return DeviceProofModel(
      purpose: 1,
      status: status,
      requestId: 5,
      generation: 39,
      publicKey: Uint8List(65)..[0] = 4,
      signature: Uint8List(64)..[0] = status == 2 ? 1 : 0,
    );
  }
}

void main() {
  final nonce = List.generate(32, (i) => i);

  test('an ok proof becomes the signed entity', () async {
    final source = _ProofSource();
    final proof = await DeviceRepositoryImpl(source).requestBindProof(nonce);
    expect(source.nonces.single, nonce);
    expect(proof.generation, 39);
    expect(proof.publicKey, hasLength(65));
    expect(proof.signature.first, 1);
  });

  test('device refusals map to proof kinds', () async {
    final cases = {
      3: DeviceExceptionKind.proofFailed,
      4: DeviceExceptionKind.proofUnavailable,
      5: DeviceExceptionKind.proofUnavailable,
      6: DeviceExceptionKind.proofFailed,
    };
    for (final MapEntry(key: status, value: kind) in cases.entries) {
      await expectLater(
        DeviceRepositoryImpl(_ProofSource(status: status))
            .requestBindProof(nonce),
        throwsA(isDeviceException(kind)),
        reason: 'status $status',
      );
    }
  });

  test('no capability sends nothing; transport errors are translated',
      () async {
    final unsupported = _ProofSource(supported: false);
    await expectLater(
      DeviceRepositoryImpl(unsupported).requestBindProof(nonce),
      throwsA(isDeviceException(DeviceExceptionKind.unsupportedDevice)),
    );
    expect(unsupported.nonces, isEmpty);
    await expectLater(
      DeviceRepositoryImpl(_ProofSource(error: const FormatException('x')))
          .requestBindProof(nonce),
      throwsA(isDeviceException(DeviceExceptionKind.invalidResponse)),
    );
  });

  test('the simulator never fabricates a proof', () async {
    final simulator = SimulatorDeviceBleDataSource();
    await simulator.connect(SimulatorDeviceBleDataSource.deviceId);
    expect(simulator.supportsDeviceProof, isFalse);
    await expectLater(
      DeviceRepositoryImpl(simulator).requestBindProof(nonce),
      throwsA(isDeviceException(DeviceExceptionKind.unsupportedDevice)),
    );
    await simulator.close();
  });
}
