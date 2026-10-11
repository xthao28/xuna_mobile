import 'package:flutter/material.dart';
import 'package:xuna_mobile/assets.dart';

enum SnackBarType {
  success,
  failure,
  info;

  Color get backgroundColor {
    switch (this) {
      case SnackBarType.success:
        return const Color(0xFFECFBF1);
      case SnackBarType.failure:
        return const Color(0xFFFEEEEC);
      case SnackBarType.info:
        return const Color(0xFF44494D);
    }
  }

  Color get borderColor {
    switch (this) {
      case SnackBarType.success:
        return const Color(0xFF379000);
      case SnackBarType.failure:
        return const Color(0xFFFE0000);
      case SnackBarType.info:
        return const Color(0xFF44494D);
    }
  }

  Color get textColor {
    switch (this) {
      case SnackBarType.success:
      case SnackBarType.failure:
        return Colors.black;
      case SnackBarType.info:
        return Colors.white;
    }
  }

  String? get iconPath {
    switch (this) {
      case SnackBarType.success:
        return Assets.ASSETS_ICONS_IC_SNACK_BAR_SUCCESS_SVG;
      case SnackBarType.failure:
        return Assets.ASSETS_ICONS_IC_SNACK_BAR_FAILURE_SVG;
      default:
        return null;
    }
  }
}
