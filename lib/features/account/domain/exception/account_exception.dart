import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';

enum AccountExceptionKind {
  /// Firebase is not initialized (missing config) on this build.
  notConfigured,

  /// The owner closed the Google account picker.
  cancelled,
  notSignedIn,
  network,
  signInFailed,

  /// No backend URL was compiled in (`--dart-define=XUNA_API_BASE_URL`).
  cloudNotConfigured,

  /// The backend is unreachable or returned 5xx.
  cloudUnavailable,

  /// The backend rejected the token (401/403).
  cloudRejected,
}

class AccountException extends AppException {
  const AccountException(this.kind, {this.rootException})
      : super(AppExceptionType.custom);

  final AccountExceptionKind kind;
  final Object? rootException;

  @override
  String toString() => 'AccountException($kind, root: $rootException)';
}
