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
        AccountExceptionKind.deviceProofUnsupported =>
          LocaleKeys.account_errorDeviceProofUnsupported.tr,
        AccountExceptionKind.challengeInvalid =>
          LocaleKeys.account_errorChallengeInvalid.tr,
        AccountExceptionKind.invalidSignature =>
          LocaleKeys.account_errorInvalidSignature.tr,
        AccountExceptionKind.petAlreadyBound =>
          LocaleKeys.account_errorPetAlreadyBound.tr,
        AccountExceptionKind.deviceKeyMismatch =>
          LocaleKeys.account_errorDeviceKeyMismatch.tr,
        AccountExceptionKind.petNotFound =>
          LocaleKeys.account_errorPetNotFound.tr,
        AccountExceptionKind.consentRequired =>
          LocaleKeys.account_errorConsentRequired.tr,
        AccountExceptionKind.consentVersionConflict =>
          LocaleKeys.account_errorConsentVersionConflict.tr,
        AccountExceptionKind.providerUnavailable =>
          LocaleKeys.account_errorProviderUnavailable.tr,
        AccountExceptionKind.invalidInput =>
          LocaleKeys.account_errorInvalidInput.tr,
      };
}
