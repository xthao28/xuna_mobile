import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/account/data/data_source/account_auth_data_source.dart';
import 'package:xuna_mobile/features/account/data/data_source/cloud_remote_data_source.dart';
import 'package:xuna_mobile/features/account/data/model/account_model.dart';
import 'package:xuna_mobile/features/account/data/repository/account_repository_impl.dart';
import 'package:xuna_mobile/features/account/data/repository/cloud_repository_impl.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';

class _Auth implements AccountAuthDataSource {
  Object? error;
  String? token = 'firebase-id-token';

  @override
  Stream<AccountModel?> changes() =>
      Stream.value(const AccountModel(uid: 'u1', email: 'a@b.c'));

  @override
  Future<AccountModel> signInWithGoogle() async {
    final failure = error;
    if (failure != null) throw failure;
    return const AccountModel(uid: 'u1', email: 'a@b.c');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<String?> idToken() async => token;
}

class _Remote extends Fake implements CloudRemoteDataSource {
  _Remote({this.configured = true});
  @override
  final bool configured;
  Object? error;
  Map<String, dynamic> body = {'userId': 'xuna-user'};
  String? seenToken;

  @override
  Future<Map<String, dynamic>> getMe(String idToken) async {
    seenToken = idToken;
    final failure = error;
    if (failure != null) throw failure;
    return body;
  }
}

Matcher _kind(AccountExceptionKind kind) =>
    throwsA(isA<AccountException>().having((e) => e.kind, 'kind', kind));

DioException _http(int status) => DioException(
      requestOptions: RequestOptions(path: '/v1/me'),
      response: Response(
          requestOptions: RequestOptions(path: '/v1/me'), statusCode: status),
    );

void main() {
  test('maps the Firebase account and translates platform errors', () async {
    final auth = _Auth();
    final repository = AccountRepositoryImpl(auth);
    expect(await repository.watchAccount().first,
        const Account(uid: 'u1', email: 'a@b.c'));
    expect((await repository.signInWithGoogle()).uid, 'u1');
    final cases = <Object, AccountExceptionKind>{
      PlatformException(code: 'sign_in_canceled'):
          AccountExceptionKind.cancelled,
      PlatformException(code: 'network_error'): AccountExceptionKind.network,
      FirebaseAuthException(code: 'network-request-failed'):
          AccountExceptionKind.network,
      TimeoutException('slow'): AccountExceptionKind.network,
      PlatformException(code: 'sign_in_failed'):
          AccountExceptionKind.signInFailed,
      const AccountException(AccountExceptionKind.notConfigured):
          AccountExceptionKind.notConfigured,
    };
    for (final entry in cases.entries) {
      auth.error = entry.key;
      await expectLater(repository.signInWithGoogle(), _kind(entry.value));
    }
    auth.token = null;
    await expectLater(
        repository.idToken(), _kind(AccountExceptionKind.notSignedIn));
  });

  test('cloud profile uses the Firebase token and maps failures', () async {
    final remote = _Remote();
    final auth = _Auth();
    final cloud = CloudRepositoryImpl(remote, AccountRepositoryImpl(auth));
    expect(await cloud.fetchProfile(), const CloudProfile(userId: 'xuna-user'));
    expect(remote.seenToken, 'firebase-id-token');
    remote.error = _http(401);
    await expectLater(
        cloud.fetchProfile(), _kind(AccountExceptionKind.cloudRejected));
    remote.error = _http(503);
    await expectLater(
        cloud.fetchProfile(), _kind(AccountExceptionKind.cloudUnavailable));
    remote
      ..error = null
      ..body = {'userId': 1};
    await expectLater(
        cloud.fetchProfile(), _kind(AccountExceptionKind.cloudUnavailable));
    auth.token = null;
    await expectLater(
        cloud.fetchProfile(), _kind(AccountExceptionKind.notSignedIn));
  });

  test('no backend URL means cloud is not configured and no token is used',
      () async {
    final remote = _Remote(configured: false);
    final cloud = CloudRepositoryImpl(remote, AccountRepositoryImpl(_Auth()));
    await expectLater(
        cloud.fetchProfile(), _kind(AccountExceptionKind.cloudNotConfigured));
    expect(remote.seenToken, isNull);
  });
}
