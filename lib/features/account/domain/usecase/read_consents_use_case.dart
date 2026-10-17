import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';

class ReadConsentsUseCase extends NoInputUseCase<ConsentSettings> {
  const ReadConsentsUseCase(this._repository);
  final CloudRepository _repository;
  @override
  Future<ConsentSettings> execute() => _repository.readConsents();
}
