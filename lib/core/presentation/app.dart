import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xuna_mobile/core/presentation/controllers/app_controller.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_page.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/routes/app_pages.dart';
import 'package:xuna_mobile/routes/app_routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/utils/keyboard.dart';

class App extends BaseGetPage<AppController> {
  App({super.key});

  final botToastBuilder = BotToastInit();

  @override
  final isAppWidget = true;

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      onTap: KeyBoard.hide,
      child: GetMaterialApp(
        title: 'XUNA',
        locale: const Locale('vi', 'VN'),
        translationsKeys: AppTranslation.translations,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash.path,
        getPages: AppPages.pages,
        localizationsDelegates: const [
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate
        ],
        supportedLocales: const [
          Locale('vi', 'VN'),
          // Locale('en', 'US'),
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundColorLight,
          appBarTheme: const AppBarTheme(
            color: AppColors.backgroundColorLight,
          ),
        ),
        builder: (context, child) {
          return botToastBuilder(context, child);
        },
        navigatorObservers: [BotToastNavigatorObserver()],
      ),
    );
  }
}
