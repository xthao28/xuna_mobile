import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_pet.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Binds the connected device's pet to the signed-in owner: backend
/// challenge → device signs it over BLE (Identity V2) → `POST /v1/pets`.
///
/// Order matters: no proof is requested without a fresh challenge and no
/// bind is sent without a device proof. Nothing is retried automatically; a
/// new attempt starts with a new challenge. Throws [DeviceException]
/// (`identityUnavailable`, proof and BLE kinds) or [AccountException].
/// The audit record is written by the backend.
class BindPetToCloudUseCase extends NoInputUseCase<CloudPet> {
  const BindPetToCloudUseCase(this._device, this._cloud);

  final DeviceRepository _device;
  final CloudRepository _cloud;

  @override
  Future<CloudPet> execute() async {
    if (!_device.supportsDeviceProof) {
      throw const AccountException(AccountExceptionKind.deviceProofUnsupported);
    }
    final identity = await _device.readIdentity();
    if (identity == null) {
      throw const DeviceException(DeviceExceptionKind.identityUnavailable);
    }
    final challenge = await _cloud.createChallenge(identity.petId);
    final proof = await _device.requestBindProof(challenge.nonce);
    return _cloud.bindPet(
      identity: identity,
      challenge: challenge,
      proof: proof,
    );
  }
}
