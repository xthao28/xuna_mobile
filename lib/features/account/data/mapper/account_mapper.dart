import 'package:xuna_mobile/features/account/data/model/account_model.dart';
import 'package:xuna_mobile/features/account/domain/entity/account.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class AccountMapper extends BaseDataMapper<AccountModel, Account> {
  @override
  Account mapToEntity(AccountModel? data) {
    if (data == null || data.uid.isEmpty) {
      throw const FormatException('Missing account');
    }
    return Account(
        uid: data.uid, email: data.email, displayName: data.displayName);
  }
}
