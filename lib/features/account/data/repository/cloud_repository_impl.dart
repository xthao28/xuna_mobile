import 'dart:async';

import 'package:dio/dio.dart';
import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/features/account/data/data_source/cloud_remote_data_source.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_profile.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';
import 'package:xuna_mobile/features/account/domain/repository/account_repository.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';

class CloudRepositoryImpl extends BaseRepository implements CloudRepository {
  CloudRepositoryImpl(this._remote, this._accounts);

  final CloudRemoteDataSource _remote;
  final AccountRepository _accounts;

  @override
  Future<CloudProfile> fetchProfile() async {
    if (!_remote.configured) {
      throw const AccountException(AccountExceptionKind.cloudNotConfigured);
    }
    final token = await _accounts.idToken();
    try {
      final json = await _remote.getMe(token);
      final userId = json['userId'];
      if (userId is! String || userId.isEmpty) {
        throw const FormatException('userId');
      }
      return CloudProfile(userId: userId);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(translate(error), stackTrace);
    }
  }

  static AccountException translate(Object error) => switch (error) {
        AccountException() => error,
        DioException(response: Response(statusCode: 401 || 403)) =>
          AccountException(AccountExceptionKind.cloudRejected,
              rootException: error),
        _ => AccountException(AccountExceptionKind.cloudUnavailable,
            rootException: error),
      };
}
