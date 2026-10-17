import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';

enum DeviceExceptionKind {
  bluetoothUnsupported,
  bluetoothOff,
  deviceNotFound,
  unsupportedDevice,
  notConnected,
  disconnected,
  busy,
  timeout,

  /// A command was sent but its result never arrived. It is not resent.
  outcomeUnknown,

  /// The device answered with a non-zero result code.
  rejected,
  feedbackExpired,

  /// Feedback was requested while no suggestion is pending.
  noPendingSuggestion,
  invalidResponse,
  communicationFailed,

  /// The device cannot report a durable PetId (old firmware, Egg, safe mode
  /// or simulator), so an export would not identify the pet.
  identityUnavailable,

  /// The export file could not be written locally.
  exportFailed,

  /// The device cannot sign a proof now (no key or identity yet, or the
  /// purpose is not supported).
  proofUnavailable,

  /// The device refused the proof request or signing failed.
  proofFailed,
}

/// Failures of the device feature. Carries no UI text: presentation maps
/// [kind] to a localized message.
class DeviceException extends AppException {
  const DeviceException(
    this.kind, {
    this.resultCode,
    this.rootException,
  }) : super(AppExceptionType.custom);

  final DeviceExceptionKind kind;

  /// Device result code when [kind] is [DeviceExceptionKind.rejected].
  final int? resultCode;
  final Object? rootException;

  @override
  String toString() =>
      'DeviceException($kind, resultCode: $resultCode, root: $rootException)';
}
