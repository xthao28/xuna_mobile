import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/bindings/base_bindings.dart';
import 'package:xuna_mobile/features/account/data/data.src.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';
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

  /// XUNA Cloud base URL, e.g. `--dart-define=XUNA_API_BASE_URL=http://10.0.2.2:8000`.
  static const apiBaseUrl = String.fromEnvironment('XUNA_API_BASE_URL');

  @override
  void bindingsRepository() {
    Get.lazyPut<DeviceBleDataSource>(
      () => simulator
          ? SimulatorDeviceBleDataSource()
          : DeviceBleDataSourceImpl(),
    );
    Get.lazyPut<DeviceRepository>(() => DeviceRepositoryImpl(sl()));
    Get.lazyPut<AccountAuthDataSource>(() => AccountAuthDataSourceImpl());
    Get.lazyPut<AccountRepository>(() => AccountRepositoryImpl(sl()));
    Get.lazyPut<CloudRemoteDataSource>(
      () => CloudRemoteDataSourceImpl(baseUrl: apiBaseUrl),
    );
    Get.lazyPut<CloudRepository>(() => CloudRepositoryImpl(sl(), sl()));
    Get.lazyPut<DeviceExportLocalDataSource>(
      () => DeviceExportLocalDataSourceImpl(),
    );
    Get.lazyPut<DeviceExportRepository>(
      () => DeviceExportRepositoryImpl(
        sl(),
        appVersion: _appVersion(),
      ),
    );
  }

  /// `versionName+versionCode`, or `unknown` before AppInfo is ready.
  static String _appVersion() {
    if (!Get.isRegistered<AppInfo>()) return 'unknown';
    final info = sl<AppInfo>();
    return info.versionName.isEmpty
        ? 'unknown'
        : '${info.versionName}+${info.versionCode}';
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
    Get.lazyPut(() => ReadPetIdentityUseCase(sl()));
    Get.lazyPut(() => ExportDeviceDataUseCase(sl(), sl()));
    Get.lazyPut(() => WatchAccountUseCase(sl()));
    Get.lazyPut(() => SignInWithGoogleUseCase(sl()));
    Get.lazyPut(() => SignOutUseCase(sl()));
    Get.lazyPut(() => CheckCloudConnectionUseCase(sl()));
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
        readPetIdentity: sl(),
        exportDeviceData: sl(),
        watchAccount: sl(),
        signInWithGoogle: sl(),
        signOut: sl(),
        checkCloudConnection: sl(),
        parseTextIntent: sl(),
        extractCandidate: sl(),
        confirmCandidate: sl(),
      ),
    );
  }
}
