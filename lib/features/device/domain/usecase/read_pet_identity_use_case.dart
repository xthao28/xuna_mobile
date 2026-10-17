import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Null when the firmware lacks the Identity V1 capability or has no ready
/// identity yet (Egg or safe mode).
class ReadPetIdentityUseCase extends NoInputUseCase<PetIdentity?> {
  const ReadPetIdentityUseCase(this._repository);
  final DeviceRepository _repository;
  @override
  Future<PetIdentity?> execute() => _repository.readIdentity();
}
