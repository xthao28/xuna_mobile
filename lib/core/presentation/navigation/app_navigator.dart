import 'package:flutter/material.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_bts_dialog.dart';
import 'snack_bar_type.dart';

enum DialogIconType {
  success,
  failure,
  note,
}

abstract class AppNavigator {
  Future<T?>? toNamed<T>(
    String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  });

  Future<T?>? offNamed<T>(
    String page, {
    dynamic arguments,
    int? id,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
  });

  void back<T>({
    T? result,
    bool closeOverlays = false,
    bool canPop = true,
    int? id,
  });

  Future<T?>? offAllNamed<T>(
    String newRouteName, {
    RoutePredicate? predicate,
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  });

  Future<T?>? toNamedFactory<T>(
    String page, {
    dynamic arguments,
    int? id,
    Map<String, String>? parameters,
  });

  void until(RoutePredicate predicate, {int? id});

  /// Show bottom sheet phức tạp cho [BaseGetBtsDialog] có controller
  Future<T?>? showBottomSheet<T>(
    BaseGetBtsDialog bottomSheet, {
    Object? arguments,
  });

  /// Show bottom sheet đơn giản
  Future<T?>? bottomSheet<T>(
    Widget bottomsheet, {
    bool isScrollControlled = false,
  });

  /// Show dialog phức tạp cho [BaseGetBtsDialog] có controller
  Future<T?>? showDialog<T>(
    BaseGetBtsDialog dialog, {
    Object? arguments,
    bool barrierDismissible = true,
  });

  /// Show dialog đơn giản
  Future<T?>? dialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
  });

  Future<void>? showNotificationDialog({
    required String message,
    VoidCallback? onClose,
    bool barrierDismissible = false,
  });

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
  });

  Future<void>? showConfirmDialog({
    required String title,
    String? subtitle,
    String? confirmTitle,
    String? cancelTitle,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = false,
  });

  Future<void>? showErrorDialog({
    required String errorMessage,
    bool barrierDismissible = false,
  });

  void showSnackBar<T>(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarType type = SnackBarType.failure,
    Alignment? align,
  });

  void dismissDialog();
}
