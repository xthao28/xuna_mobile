import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/bindings/base_bindings.dart';
import 'package:xuna_mobile/features/conversation/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/data/data.src.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';
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
    Get.lazyPut(() => ReadLearningExplanationUseCase(sl()));
    Get.lazyPut(() => ForgetMemoriesUseCase(sl()));
    Get.lazyPut(() => const ParseTextIntentUseCase());
    Get.lazyPut(() => const ExtractCandidateUseCase());
    Get.lazyPut(() => ConfirmCandidateUseCase(sl()));
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
        readExplanation: sl(),
        forgetMemories: sl(),
        parseTextIntent: sl(),
        extractCandidate: sl(),
        confirmCandidate: sl(),
      ),
    );
  }
}
