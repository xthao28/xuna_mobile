import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/account.dart';
import 'package:xuna_mobile/features/account/domain/repository/account_repository.dart';

class WatchAccountUseCase extends NoInputUseCase<Stream<Account?>> {
  const WatchAccountUseCase(this._repository);
  final AccountRepository _repository;
  @override
  Stream<Account?> execute() => _repository.watchAccount();
}
