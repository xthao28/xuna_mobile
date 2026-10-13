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

  /// Feedback was requested while no suggestion is pending.
  noPendingSuggestion,
  invalidResponse,
  communicationFailed,
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
