import 'package:event_bus/event_bus.dart';
import 'package:xuna_mobile/core/data/data_source/local/local_src.dart';
import 'package:xuna_mobile/core/domain/entity/app_data.dart';
import 'package:xuna_mobile/core/domain/entity/app_data_impl.dart';
import 'package:xuna_mobile/core/presentation/controllers/app_controller.dart';
import 'package:xuna_mobile/core/presentation/navigation/navigation_src.dart';
import 'package:xuna_mobile/shared/exceptions/exception_handler.dart';
import 'package:xuna_mobile/shared/utils/utils_src.dart';
import 'package:get/get.dart';

import 'base_bindings.dart';

class AppBinding extends BaseBindings {
  Future<void> bind() async {
    await bindingsCore();
    dependencies();
  }

  Future<void> bindingsCore() async {
    Get.put<AppData>(AppDataImpl(), permanent: true);
    Get.put<EventBus>(EventBus(), permanent: true);
    await [
      Get.putAsync<AppHive>(
        AppHiveImpl().init,
        permanent: true,
      ),
      Get.putAsync(AppInfo().init, permanent: true)
    ].wait;
    Get.put<AppNavigator>(AppNavigatorImpl(), permanent: true);
    Get.put(ExceptionHandler(nav: sl()), permanent: true);
  }

  @override
  void bindingsController() {
    Get.put(AppController(), permanent: true);
  }

  @override
  void bindingsRepository() {}

  @override
  void bindingsUseCase() {}
}
