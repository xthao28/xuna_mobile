import 'package:xuna_mobile/features/account/domain/entity/cloud_challenge.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_pet.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_profile.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_bind_proof.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';

/// XUNA Cloud backend (contract draft CLD-02). Every method throws
/// [AccountException]: `cloud*`, `notSignedIn`, or the kind of the backend
/// problem `code`. Mutations send a fresh `Idempotency-Key` per call.
abstract interface class CloudRepository {
  Future<CloudProfile> fetchProfile();

  /// `POST /v1/devices/challenges` for the device-issued [petId].
  Future<CloudChallenge> createChallenge(String petId);

  /// `POST /v1/pets` with the device's signed proof over [challenge].
  Future<CloudPet> bindPet({
    required PetIdentity identity,
    required CloudChallenge challenge,
    required DeviceBindProof proof,
  });

  /// Pets bound to the signed-in owner.
  Future<List<CloudPet>> listPets();

  Future<ConsentSettings> readConsents();

  /// Saves [desired]; its `version` is sent as `expectedVersion`.
  Future<ConsentSettings> updateConsents(ConsentSettings desired);

  /// Streams reply text for one turn (`POST /v1/conversations/{petId}/turns`,
  /// SSE). The stream fails with [AccountException] (for example
  /// `providerUnavailable` or `consentRequired`). Nothing is stored.
  Stream<String> streamReply({required String petId, required String text});
}
