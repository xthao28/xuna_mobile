import 'package:xuna_mobile/features/device/data/model/pet_identity_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class PetIdentityMapper extends BaseDataMapper<PetIdentityModel, PetIdentity> {
  @override
  PetIdentity mapToEntity(PetIdentityModel? data) {
    if (data == null || !data.ready) {
      throw const FormatException('Missing pet identity');
    }
    return PetIdentity(
      petId: data.petId.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      origin: switch (data.originCode) {
        1 => PetOrigin.hatchedOnDevice,
        2 => PetOrigin.hatchedViaApp,
        3 => PetOrigin.migratedFromV1,
        _ => throw const FormatException('origin'),
      },
      snapshotGeneration: data.snapshotGeneration,
    );
  }
}
