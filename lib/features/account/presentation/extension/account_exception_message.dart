import 'package:get/get.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

extension AccountExceptionMessage on AccountException {
  String get localizedMessage => switch (kind) {
        AccountExceptionKind.notConfigured =>
          LocaleKeys.account_errorNotConfigured.tr,
        AccountExceptionKind.cancelled => LocaleKeys.account_errorCancelled.tr,
        AccountExceptionKind.notSignedIn =>
          LocaleKeys.account_errorNotSignedIn.tr,
        AccountExceptionKind.network => LocaleKeys.account_errorNetwork.tr,
        AccountExceptionKind.signInFailed =>
          LocaleKeys.account_errorSignInFailed.tr,
        AccountExceptionKind.cloudNotConfigured =>
          LocaleKeys.account_errorCloudNotConfigured.tr,
        AccountExceptionKind.cloudUnavailable =>
          LocaleKeys.account_errorCloudUnavailable.tr,
        AccountExceptionKind.cloudRejected =>
          LocaleKeys.account_errorCloudRejected.tr,
      };
}
