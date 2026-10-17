import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:xuna_mobile/features/account/data/model/account_model.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';

/// Firebase Auth with the Google provider (owner choice 2026-10-17).
abstract interface class AccountAuthDataSource {
  Stream<AccountModel?> changes();

  /// Throws [AccountException] `cancelled` when the picker is closed.
  Future<AccountModel> signInWithGoogle();

  Future<void> signOut();

  /// Null when signed out.
  Future<String?> idToken();
}

class AccountAuthDataSourceImpl implements AccountAuthDataSource {
  AccountAuthDataSourceImpl({GoogleSignIn? googleSignIn})
      : _google = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  static const _timeout = Duration(seconds: 30);

  /// The owner types credentials in the Google picker; network timeouts
  /// must not cancel a human (board/emulator test 2026-10-17).
  static const _pickerTimeout = Duration(minutes: 5);
  static const _tokenTimeout = Duration(seconds: 10);

  final GoogleSignIn _google;

  FirebaseAuth get _auth {
    if (Firebase.apps.isEmpty) {
      throw const AccountException(AccountExceptionKind.notConfigured);
    }
    return FirebaseAuth.instance;
  }

  static AccountModel _model(User user) => AccountModel(
      uid: user.uid, email: user.email, displayName: user.displayName);

  @override
  Stream<AccountModel?> changes() {
    if (Firebase.apps.isEmpty) return Stream.value(null);
    return _auth
        .authStateChanges()
        .map((user) => user == null ? null : _model(user));
  }

  @override
  Future<AccountModel> signInWithGoogle() async {
    final auth = _auth;
    final picked = await _google.signIn().timeout(_pickerTimeout);
    if (picked == null) {
      throw const AccountException(AccountExceptionKind.cancelled);
    }
    final tokens = await picked.authentication.timeout(_timeout);
    final credential = GoogleAuthProvider.credential(
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
    final result =
        await auth.signInWithCredential(credential).timeout(_timeout);
    final user = result.user;
    if (user == null) {
      throw const AccountException(AccountExceptionKind.signInFailed);
    }
    return _model(user);
  }

  @override
  Future<void> signOut() async {
    await _google.signOut().timeout(_timeout);
    if (Firebase.apps.isNotEmpty) await _auth.signOut().timeout(_timeout);
  }

  @override
  Future<String?> idToken() async {
    if (Firebase.apps.isEmpty) return null;
    return _auth.currentUser?.getIdToken().timeout(_tokenTimeout);
  }
}
