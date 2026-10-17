import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';

import '../../../../helpers/device_matchers.dart';
import '../../../../helpers/fake_cloud.dart';

class _Device extends Fake implements DeviceRepository {
  _Device(this.calls, {this.proofSupported = true, this.identity, this.error});

  final List<String> calls;
  final bool proofSupported;
  final PetIdentity? identity;
  final DeviceException? error;

  @override
  bool get supportsDeviceProof => proofSupported;

  @override
  Future<PetIdentity?> readIdentity() async {
    calls.add('identity');
    return identity;
  }

  @override
  Future<DeviceBindProof> requestBindProof(List<int> nonce) async {
    calls.add('proof:${nonce.length}');
    final failure = error;
    if (failure != null) throw failure;
    return DeviceBindProof(
      generation: 40,
      publicKey: [4, ...List.filled(64, 1)],
      signature: List.filled(64, 2),
    );
  }
}

const _identity = PetIdentity(
  petId: 'd945c77026fd4f4a8a899bbff4aeed86',
  origin: PetOrigin.migratedFromV1,
  snapshotGeneration: 39,
);

void main() {
  test('challenge, then device proof, then bind with the signed generation',
      () async {
    final cloud = FakeCloud();
    final device = _Device(cloud.calls, identity: _identity);
    final pet = await BindPetToCloudUseCase(device, cloud).execute();
    expect(cloud.calls, [
      'identity',
      'challenge:${_identity.petId}',
      'proof:32',
      'bind:${_identity.petId}:40',
    ]);
    expect(pet.petId, _identity.petId);
  });

  test('no proof capability: nothing is read or sent', () async {
    final cloud = FakeCloud();
    final device = _Device(cloud.calls, proofSupported: false);
    await expectLater(
      BindPetToCloudUseCase(device, cloud).execute(),
      throwsA(isA<AccountException>().having(
          (e) => e.kind, 'kind', AccountExceptionKind.deviceProofUnsupported)),
    );
    expect(cloud.calls, isEmpty);
  });

  test('no identity: no challenge', () async {
    final cloud = FakeCloud();
    await expectLater(
      BindPetToCloudUseCase(_Device(cloud.calls), cloud).execute(),
      throwsA(isDeviceException(DeviceExceptionKind.identityUnavailable)),
    );
    expect(cloud.calls, ['identity']);
  });

  test('no challenge: no proof; no proof: no bind', () async {
    final cloud = FakeCloud()
      ..cloudError =
          const AccountException(AccountExceptionKind.cloudUnavailable);
    await expectLater(
      BindPetToCloudUseCase(_Device(cloud.calls, identity: _identity), cloud)
          .execute(),
      throwsA(isA<AccountException>()),
    );
    expect(cloud.calls, ['identity', 'challenge:${_identity.petId}']);

    final second = FakeCloud();
    final device = _Device(second.calls,
        identity: _identity,
        error: const DeviceException(DeviceExceptionKind.timeout));
    await expectLater(BindPetToCloudUseCase(device, second).execute(),
        throwsA(isDeviceException(DeviceExceptionKind.timeout)));
    expect(second.calls.last, 'proof:32');
    expect(second.pets, isEmpty);
  });
}
