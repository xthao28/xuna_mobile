import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/core/presentation/navigation/app_navigator.dart';
import 'package:xuna_mobile/core/presentation/navigation/snack_bar_type.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_bts_dialog.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

class AppNavigatorImpl extends AppNavigator {
  @override
  Future<T?>? toNamed<T>(
    String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    return Get.toNamed(
      page,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  @override
  Future<T?>? offNamed<T>(
    String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  }) {
    return Get.offNamed(
      page,
      arguments: arguments,
      id: id,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
    );
  }

  @override
  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  }) {
    Get.back<T>(
      result: result,
      closeOverlays: closeOverlays,
      canPop: canPop,
      id: id,
    );
  }

  @override
  Future<T?>? offAllNamed<T>(
    String newRouteName, {
    RoutePredicate? predicate,
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    return Get.offAllNamed(
      newRouteName,
      predicate: predicate,
      arguments: arguments,
      id: id,
      parameters: parameters,
    );
  }

  @override
  Future<T?>? toNamedFactory<T>(
    String page, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  }) {
    return Get.toNamed(
      page,
      arguments: arguments,
      id: id,
      preventDuplicates: false,
      parameters: parameters,
    );
  }

  @override
  void until(RoutePredicate predicate, {int? id}) {
    return Get.until(predicate, id: id);
  }

  @override
  Future<T?>? showBottomSheet<T>(
    BaseGetBtsDialog bottomSheet, {
    Object? arguments,
  }) {
    return Get.bottomSheet(
      bottomSheet,
      settings: arguments != null ? RouteSettings(arguments: arguments) : null,
      isScrollControlled: true,
    );
  }

  @override
  Future<T?>? bottomSheet<T>(
    Widget bottomsheet, {
    bool isScrollControlled = false,
  }) {
    return Get.bottomSheet(
      bottomsheet,
      isScrollControlled: isScrollControlled,
    );
  }

  @override
  Future<T?>? showDialog<T>(
    BaseGetBtsDialog dialog, {
    Object? arguments,
    bool barrierDismissible = true,
  }) {
    return Get.dialog(
      dialog,
      routeSettings:
          arguments != null ? RouteSettings(arguments: arguments) : null,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<T?>? dialog<T>(
    Widget widget, {
    bool barrierDismissible = false,
  }) {
    return Get.dialog(
      widget,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  void showSnackBar<T>(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarType type = SnackBarType.failure,
    Alignment? align,
  }) {
    BotToast.showCustomText(
      duration: message.length > 100 ? 5.seconds : duration,
      align: align ?? Alignment.topCenter,
      toastBuilder: (cancel) {
        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppDimens.paddingSmall),
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding5,
              vertical: AppDimens.padding10,
            ),
            decoration: BoxDecoration(
              color: type.backgroundColor,
              border: Border.all(color: type.borderColor),
              borderRadius: BorderRadius.circular(
                AppDimens.padding6,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(2, 4),
                  blurRadius: 8.1,
                  color: Colors.black.withValues(alpha: 0.15),
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (type.iconPath != null)
                        SvgPicture.asset(type.iconPath!).paddingOnly(
                          right: AppDimens.paddingVerySmall,
                        ),
                      Expanded(
                        child: Text(
                          message,
                          style: AppTextStyle.font14Bo.copyWith(
                            color: type.textColor,
                          ),
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                // if (mainButton != null) mainButton,
                InkWell(
                  onTap: cancel,
                  child: Icon(
                    Icons.close,
                    color: type.textColor,
                  ).paddingOnly(left: AppDimens.padding14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDialog(
    Widget widget, {
    bool barrierDismissible = false,
  }) {
    return Get.dialog(
      PopScope(
        canPop: barrierDismissible,
        child: widget,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<void>? showNotificationDialog({
    required String message,
    VoidCallback? onClose,
    bool barrierDismissible = false,
  }) {
    return _showDialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
          vertical: AppDimens.defaultPadding,
          horizontal: AppDimens.padding24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_none,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Text(
                      message,
                      style: AppTextStyle.font14Re,
                      textAlign: TextAlign.center,
                      maxLines: 10,
                    ),
                  ),
                ),
              ],
            ).paddingAll(AppDimens.defaultPadding),
            const Divider(height: 1),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  dismissDialog();
                  onClose?.call();
                },
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Text(
                  LocaleKeys.dialog_close.tr,
                  style: AppTextStyle.font14Re.copyWith(
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  Widget _buildDialogIcon(DialogIconType iconType) {
    switch (iconType) {
      case DialogIconType.success:
        return SvgPicture.asset(
          Assets.ASSETS_ICONS_IC_SUCCESS_SVG,
          width: 60,
          height: 60,
        );
      case DialogIconType.failure:
        return SvgPicture.asset(
          Assets.ASSETS_ICONS_IC_FAILURE_SVG,
          width: 60,
          height: 60,
        );
      case DialogIconType.note:
        return SvgPicture.asset(
          Assets.ASSETS_ICONS_IC_NOTE_SVG,
          width: 60,
          height: 60,
        );
    }
  }

  @override
  Future<void>? showInfoDialog({
    required String title,
    required String subtitle,
    required DialogIconType iconType,
    bool swapTitleAndIcon = false,
    String? confirmTitle,
    String? cancelTitle,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showConfirmButton = true,
    bool showCancelButton = true,
    bool barrierDismissible = false,
  }) {
    assert(
      showConfirmButton || showCancelButton,
      'At least one of showConfirmButton or showCancelButton must be true',
    );
    final titleAndIconSection = [
      Text(
        title,
        maxLines: 3,
        style: AppTextStyle.font18Bo,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      _buildDialogIcon(iconType),
    ];
    return _showDialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
          vertical: AppDimens.defaultPadding,
          horizontal: AppDimens.padding24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: swapTitleAndIcon
                  ? titleAndIconSection.reversed.toList()
                  : titleAndIconSection,
            ),
            Container(
              padding: const EdgeInsets.only(
                top: AppDimens.defaultPadding,
                bottom: AppDimens.padding24,
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Text(
                  subtitle,
                  style: AppTextStyle.font14Re,
                  textAlign: TextAlign.center,
                  maxLines: 20,
                ),
              ),
            ),
            Row(
              children: [
                if (showCancelButton)
                  Expanded(
                    child: UtilWidget.buildBackButton(
                      title: cancelTitle ?? LocaleKeys.dialog_cancel.tr,
                      borderRadius: AppDimens.radius30,
                      backgroundColor: AppColors.basicWhite,
                      textStyle: AppTextStyle.font14Re
                          .copyWith(color: AppColors.primaryColor),
                      onPressed: () {
                        dismissDialog();
                        onCancel?.call();
                      },
                    ),
                  ),
                if (showCancelButton && showConfirmButton)
                  const SizedBox(width: 20),
                if (showConfirmButton)
                  Expanded(
                    child: UtilWidget.buildSolidButton(
                      borderRadius: AppDimens.radius30,
                      textStyle: AppTextStyle.font14Re
                          .copyWith(color: AppColors.basicWhite),
                      title: confirmTitle ?? LocaleKeys.dialog_confirm.tr,
                      onPressed: () {
                        dismissDialog();
                        onConfirm?.call();
                      },
                    ),
                  )
              ],
            )
          ],
        ).paddingAll(AppDimens.padding24),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<void>? showConfirmDialog({
    required String title,
    String? subtitle,
    String? confirmTitle,
    String? cancelTitle,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = false,
  }) {
    return _showDialog(
      Dialog(
        elevation: 0,
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
          vertical: AppDimens.defaultPadding,
          horizontal: AppDimens.padding24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              maxLines: 3,
              style: AppTextStyle.font18Bo,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (subtitle != null)
              Container(
                padding: const EdgeInsets.only(
                  bottom: AppDimens.padding24,
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Text(
                    subtitle,
                    style: AppTextStyle.font14Re,
                    textAlign: TextAlign.center,
                    maxLines: 20,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: UtilWidget.buildBackButton(
                    title: cancelTitle ?? LocaleKeys.dialog_cancel.tr,
                    borderRadius: AppDimens.radius30,
                    backgroundColor: AppColors.basicWhite,
                    textStyle: AppTextStyle.font14Re
                        .copyWith(color: AppColors.primaryColor),
                    onPressed: () {
                      dismissDialog();
                      onCancel?.call();
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: UtilWidget.buildSolidButton(
                    borderRadius: AppDimens.radius30,
                    textStyle: AppTextStyle.font14Re
                        .copyWith(color: AppColors.basicWhite),
                    title: confirmTitle ?? LocaleKeys.dialog_confirm.tr,
                    onPressed: () {
                      dismissDialog();
                      onConfirm?.call();
                    },
                  ),
                )
              ],
            )
          ],
        ).paddingAll(AppDimens.padding24),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<void>? showErrorDialog({
    required String errorMessage,
    bool barrierDismissible = false,
  }) async {
    // Chỉ hiển thị 1 dialog lỗi trong một thời điểm
    if (Get.isDialogOpen == true) {
      return;
    }
    return showNotificationDialog(
      message: errorMessage,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  void dismissDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
