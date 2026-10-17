import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/features/account/data/data_source/account_auth_data_source.dart';
import 'package:xuna_mobile/features/account/data/mapper/account_mapper.dart';
import 'package:xuna_mobile/features/account/domain/entity/account.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';
import 'package:xuna_mobile/features/account/domain/repository/account_repository.dart';

class AccountRepositoryImpl extends BaseRepository
    implements AccountRepository {
  AccountRepositoryImpl(this._dataSource, {AccountMapper? mapper})
      : _mapper = mapper ?? AccountMapper();

  final AccountAuthDataSource _dataSource;
  final AccountMapper _mapper;

  @override
  Stream<Account?> watchAccount() => _dataSource.changes().map(
        (model) => model == null ? null : _mapper.mapToEntity(model),
      );

  @override
  Future<Account> signInWithGoogle() => _guard(
      () async => _mapper.mapToEntity(await _dataSource.signInWithGoogle()));

  @override
  Future<void> signOut() => _guard(_dataSource.signOut);

  @override
  Future<String> idToken() => _guard(() async {
        final token = await _dataSource.idToken();
        if (token == null || token.isEmpty) {
          throw const AccountException(AccountExceptionKind.notSignedIn);
        }
        return token;
      });

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(translate(error), stackTrace);
    }
  }

  /// Every Firebase/Google/platform error becomes an [AccountException].
  static AccountException translate(Object error) => switch (error) {
        AccountException() => error,
        TimeoutException() =>
          AccountException(AccountExceptionKind.network, rootException: error),
        FirebaseAuthException(code: 'network-request-failed') =>
          AccountException(AccountExceptionKind.network, rootException: error),
        PlatformException(code: 'network_error') =>
          AccountException(AccountExceptionKind.network, rootException: error),
        PlatformException(code: 'sign_in_canceled') => AccountException(
            AccountExceptionKind.cancelled,
            rootException: error),
        _ => AccountException(AccountExceptionKind.signInFailed,
            rootException: error),
      };
}
