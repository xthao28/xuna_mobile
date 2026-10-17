import 'package:xuna_mobile/features/account/domain/entity/account.dart';

/// Owner sign-in (Firebase Auth, Google provider). Throws [AccountException].
abstract interface class AccountRepository {
  /// Emits the current account immediately, then on every change.
  Stream<Account?> watchAccount();

  Future<Account> signInWithGoogle();

  Future<void> signOut();

  /// Fresh Firebase ID token for the backend `Authorization: Bearer` header.
  Future<String> idToken();
}
