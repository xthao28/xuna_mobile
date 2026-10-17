import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/account.dart';
import 'package:xuna_mobile/features/account/domain/repository/account_repository.dart';

class SignInWithGoogleUseCase extends NoInputUseCase<Account> {
  const SignInWithGoogleUseCase(this._repository);
  final AccountRepository _repository;
  @override
  Future<Account> execute() => _repository.signInWithGoogle();
}
