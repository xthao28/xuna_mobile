import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/repository/account_repository.dart';

/// Signs out of the cloud account only; the pet on the device is untouched.
class SignOutUseCase extends NoInputUseCase<void> {
  const SignOutUseCase(this._repository);
  final AccountRepository _repository;
  @override
  Future<void> execute() => _repository.signOut();
}
