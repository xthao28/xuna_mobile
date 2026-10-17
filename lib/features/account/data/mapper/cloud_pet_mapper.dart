import 'package:xuna_mobile/features/account/data/model/cloud_pet_model.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_pet.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class CloudPetMapper extends BaseDataMapper<CloudPetModel, CloudPet> {
  @override
  CloudPet mapToEntity(CloudPetModel? data) {
    if (data == null) throw const FormatException('Missing pet');
    return CloudPet(
      petId: data.petId,
      brainId: data.brainId,
      deviceId: data.deviceId,
      lastGeneration: data.lastGeneration,
      boundAt: data.boundAt.toUtc(),
    );
  }
}
