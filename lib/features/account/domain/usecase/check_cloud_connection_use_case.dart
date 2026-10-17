import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_profile.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';

/// Proves sign-in end to end: the backend accepts the Firebase token.
/// Sends no pet data.
class CheckCloudConnectionUseCase extends NoInputUseCase<CloudProfile> {
  const CheckCloudConnectionUseCase(this._repository);
  final CloudRepository _repository;
  @override
  Future<CloudProfile> execute() => _repository.fetchProfile();
}
