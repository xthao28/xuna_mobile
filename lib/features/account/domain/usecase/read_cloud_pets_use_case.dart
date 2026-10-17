import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_pet.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';

class ReadCloudPetsUseCase extends NoInputUseCase<List<CloudPet>> {
  const ReadCloudPetsUseCase(this._repository);
  final CloudRepository _repository;
  @override
  Future<List<CloudPet>> execute() => _repository.listPets();
}
