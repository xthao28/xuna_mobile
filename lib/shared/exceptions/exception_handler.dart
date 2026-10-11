import 'dart:io';

import 'package:xuna_mobile/core/presentation/navigation/app_navigator.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';
import 'package:xuna_mobile/shared/exceptions/base/app_exception_wrapper.dart';
import 'package:xuna_mobile/shared/exceptions/remote/remote_exception.dart';
import 'package:xuna_mobile/shared/utils/utils_src.dart';
import 'package:get/get.dart';

class ExceptionHandler {
  final AppNavigator nav;

  const ExceptionHandler({
    required this.nav,
  });

  void handleException(
    AppExceptionWrapper appExceptionWrapper,
  ) {
    switch (appExceptionWrapper.appException.appExceptionType) {
      case AppExceptionType.remote:
        final exception = appExceptionWrapper.appException as RemoteException;
        switch (exception.kind) {
          case RemoteExceptionKind.noInternet:
          case RemoteExceptionKind.timeout:
            nav.showErrorDialog(
              errorMessage: LocaleKeys.app_cannotConnectToServer.tr,
            );
            break;
          case RemoteExceptionKind.serverDefined:
            if (appExceptionWrapper.overrideMessage != null) {
              nav.showSnackBar(appExceptionWrapper.overrideMessage!);
              return;
            }

            final serverErrorMessage =
                exception.serverError?.errorMessage?.trim() ?? '';
            nav.showSnackBar(
              serverErrorMessage.isNotEmpty
                  ? serverErrorMessage
                  : LocaleKeys.app_somethingWentWrong.tr,
            );
            break;
          case RemoteExceptionKind.serverUndefined:
            // Xử lý các status code từ phổ biến
            switch (exception.httpErrorCode) {
              case HttpStatus.unauthorized:
                nav.showNotificationDialog(
                  message: LocaleKeys.dialog_error401.tr,
                );
                return;
              case HttpStatus.badRequest:
                nav.showErrorDialog(
                  errorMessage: LocaleKeys.dialog_error400.tr,
                );
                return;
              case HttpStatus.notFound:
                nav.showErrorDialog(
                  errorMessage: LocaleKeys.dialog_error404.tr,
                );
                return;
              case HttpStatus.tooManyRequests:
                nav.showErrorDialog(
                  errorMessage: LocaleKeys.dialog_error429.tr,
                );
                return;
              case HttpStatus.internalServerError:
                nav.showErrorDialog(
                  errorMessage: LocaleKeys.dialog_errorInternalServer.tr,
                );
                return;
              case HttpStatus.badGateway:
                nav.showErrorDialog(
                  errorMessage: LocaleKeys.dialog_error502.tr,
                );
                return;
              case HttpStatus.serviceUnavailable:
                nav.showErrorDialog(
                  errorMessage: LocaleKeys.dialog_error503.tr,
                );
                return;
              default:
                break;
            }
            nav.showSnackBar(LocaleKeys.app_somethingWentWrong.tr);
            break;
          case RemoteExceptionKind.network:
            nav.showErrorDialog(
              errorMessage: LocaleKeys.app_cannotConnectToServer.tr,
            );
            break;
          default:
            // Ko xử lý những exception ko cần thiết như cancellation,...
            logger.i("Unknown error: $exception");
            break;
        }
        break;
      case AppExceptionType.remoteConfig:
        break;
      case AppExceptionType.custom:
      case AppExceptionType.uncaught:
        nav.showSnackBar(
          appExceptionWrapper.appException.errorMessage ??
              LocaleKeys.app_somethingWentWrong.tr,
        );
        break;
    }
  }
}
