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

  /// The connected device cannot sign a bind proof (firmware before
  /// Identity V2, or the simulator).
  deviceProofUnsupported,

  /// `challenge_invalid`: the challenge expired or was already used.
  challengeInvalid,

  /// `invalid_signature` / `invalid_public_key`.
  invalidSignature,

  /// `pet_already_bound`: another account owns this PetId.
  petAlreadyBound,

  /// `device_key_mismatch`: the pet is pinned to a different device key.
  deviceKeyMismatch,

  /// `not_found`: the pet is not bound to this account.
  petNotFound,

  /// `consent_required`: the needed consent class is off.
  consentRequired,

  /// `consent_version_conflict`: consents changed elsewhere; reload.
  consentVersionConflict,

  /// `provider_unavailable`: the AI provider is down.
  providerUnavailable,

  /// Input rejected before sending (empty or too long).
  invalidInput,
}

class AccountException extends AppException {
  const AccountException(this.kind, {this.rootException})
      : super(AppExceptionType.custom);

  final AccountExceptionKind kind;
  final Object? rootException;

  @override
  String toString() => 'AccountException($kind, root: $rootException)';
}
