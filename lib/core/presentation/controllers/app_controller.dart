import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/routes/app_routes.dart';

class AppController extends BaseGetxController {
  @override
  void onInit() {
    super.onInit();
    _configSystemUI();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(milliseconds: 200), () {
      nav.offAllNamed(AppRoutes.home.path);
    });
  }

  void _configSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Đảm bảo status bar và navigation bar trong suốt
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor:
            Colors.transparent, // Thanh điều hướng trong suốt
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent, // Thanh trạng thái trong suốt
        statusBarIconBrightness: Brightness.dark, // Icon màu đen
      ),
    );
  }

  void changeTheme() {}

  void changeLanguage() {}
}
