import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/bindings/base_bindings.dart';
import 'package:xuna_mobile/features/device/data/simulator_device_repository.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';

class HomeBinding extends BaseBindings {
  @override
  void bindingsRepository() {
    Get.lazyPut<DeviceRepository>(() => SimulatorDeviceRepository());
  }

  @override
  void bindingsUseCase() {
    Get.lazyPut(() => RequestAnimation(Get.find()));
  }

  @override
  void bindingsController() {
    Get.lazyPut(() => HomeController(Get.find(), Get.find()));
  }
}
