import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/bindings/base_bindings.dart';
import 'package:xuna_mobile/features/conversation/domain/usecase/parse_text_intent_use_case.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_ble_data_source_impl.dart';
import 'package:xuna_mobile/features/device/data/data_source/simulator_device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/repository/device_repository_impl.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';
import 'package:xuna_mobile/features/device/domain/usecase/connect_device_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/disconnect_device_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/forget_memories_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/read_life_summary_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/read_memories_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/request_animation_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/scan_devices_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/send_feedback_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/suggest_action_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/watch_device_status_use_case.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';
import 'package:xuna_mobile/shared/utils/utils_src.dart';

/// Composition root of the home route.
///
/// The device repository is route-scoped while home is its only screen; move
/// it to `AppBinding` when a second screen needs the device (AGENTS §5.6).
class HomeBinding extends BaseBindings {
  HomeBinding({
    this.simulator = const bool.fromEnvironment('XUNA_SIMULATOR'),
  });

  /// Uses the development fake transport instead of BLE.
  final bool simulator;

  @override
  void bindingsRepository() {
    Get.lazyPut<DeviceBleDataSource>(
      () => simulator
          ? SimulatorDeviceBleDataSource()
          : DeviceBleDataSourceImpl(),
    );
    Get.lazyPut<DeviceRepository>(() => DeviceRepositoryImpl(sl()));
  }

  @override
  void bindingsUseCase() {
    Get.lazyPut(() => ScanDevicesUseCase(sl()));
    Get.lazyPut(() => ConnectDeviceUseCase(sl()));
    Get.lazyPut(() => DisconnectDeviceUseCase(sl()));
    Get.lazyPut(() => WatchDeviceStatusUseCase(sl()));
    Get.lazyPut(() => RequestAnimationUseCase(sl()));
    Get.lazyPut(() => SuggestActionUseCase(sl()));
    Get.lazyPut(() => SendFeedbackUseCase(sl()));
    Get.lazyPut(() => ReadLifeSummaryUseCase(sl()));
    Get.lazyPut(() => ReadMemoriesUseCase(sl()));
    Get.lazyPut(() => ForgetMemoriesUseCase(sl()));
    Get.lazyPut(() => const ParseTextIntentUseCase());
  }

  @override
  void bindingsController() {
    Get.lazyPut(
      () => HomeController(
        isSimulator: simulator,
        scanDevices: sl(),
        connectDevice: sl(),
        disconnectDevice: sl(),
        watchDeviceStatus: sl(),
        requestAnimation: sl(),
        suggestAction: sl(),
        sendFeedback: sl(),
        readLifeSummary: sl(),
        readMemories: sl(),
        forgetMemories: sl(),
        parseTextIntent: sl(),
      ),
    );
  }
}
