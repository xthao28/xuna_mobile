import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

extension DeviceExceptionMessage on DeviceException {
  String get localizedMessage => switch (kind) {
        DeviceExceptionKind.bluetoothUnsupported =>
          LocaleKeys.device_errorBluetoothUnsupported.tr,
        DeviceExceptionKind.bluetoothOff =>
          LocaleKeys.device_errorBluetoothOff.tr,
        DeviceExceptionKind.deviceNotFound =>
          LocaleKeys.device_errorDeviceNotFound.tr,
        DeviceExceptionKind.unsupportedDevice =>
          LocaleKeys.device_errorUnsupportedDevice.tr,
        DeviceExceptionKind.notConnected =>
          LocaleKeys.device_errorNotConnected.tr,
        DeviceExceptionKind.disconnected =>
          LocaleKeys.device_errorDisconnected.tr,
        DeviceExceptionKind.busy => LocaleKeys.device_errorBusy.tr,
        DeviceExceptionKind.timeout => LocaleKeys.device_errorTimeout.tr,
        DeviceExceptionKind.outcomeUnknown =>
          LocaleKeys.device_errorOutcomeUnknown.tr,
        DeviceExceptionKind.feedbackExpired =>
          LocaleKeys.device_errorFeedbackExpired.tr,
        DeviceExceptionKind.rejected => LocaleKeys.device_errorRejected
            .trParams({'code': '${resultCode ?? '?'}'}),
        DeviceExceptionKind.noPendingSuggestion =>
          LocaleKeys.device_errorNoPendingSuggestion.tr,
        DeviceExceptionKind.invalidResponse =>
          LocaleKeys.device_errorInvalidResponse.tr,
        DeviceExceptionKind.communicationFailed =>
          LocaleKeys.device_errorCommunicationFailed.tr,
      };
}
