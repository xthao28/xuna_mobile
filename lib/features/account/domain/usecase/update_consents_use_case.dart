import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';

/// Saves the owner's explicit consent choices. On
/// `consentVersionConflict` the caller reloads; it never overwrites a newer
/// server state blindly.
class UpdateConsentsUseCase extends UseCase<ConsentSettings, ConsentSettings> {
  const UpdateConsentsUseCase(this._repository);
  final CloudRepository _repository;
  @override
  Future<ConsentSettings> execute(ConsentSettings input) =>
      _repository.updateConsents(input);
}
