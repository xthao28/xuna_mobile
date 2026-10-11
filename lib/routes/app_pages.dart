import 'package:xuna_mobile/features/home/presentation/binding/home_binding.dart';
import 'package:xuna_mobile/features/home/presentation/home_page.dart';
import 'package:xuna_mobile/features/splash/splash_page.dart';
import 'package:xuna_mobile/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash.path,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: AppRoutes.home.path,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
