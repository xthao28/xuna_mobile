import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/conversation/domain/usecase/parse_text_intent_use_case.dart';
import 'package:xuna_mobile/features/device/data/data_source/simulator_device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/repository/device_repository_impl.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
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
import 'package:xuna_mobile/generated/locales.g.dart';

HomeController _buildController(DeviceRepository repository) => HomeController(
      isSimulator: true,
      scanDevices: ScanDevicesUseCase(repository),
      connectDevice: ConnectDeviceUseCase(repository),
      disconnectDevice: DisconnectDeviceUseCase(repository),
      watchDeviceStatus: WatchDeviceStatusUseCase(repository),
      requestAnimation: RequestAnimationUseCase(repository),
      suggestAction: SuggestActionUseCase(repository),
      sendFeedback: SendFeedbackUseCase(repository),
      readLifeSummary: ReadLifeSummaryUseCase(repository),
      readMemories: ReadMemoriesUseCase(repository),
      forgetMemories: ForgetMemoriesUseCase(repository),
      parseTextIntent: const ParseTextIntentUseCase(),
    )..isTestMode = true;

void main() {
  late DeviceRepositoryImpl repository;
  late HomeController controller;

  setUp(() {
    repository = DeviceRepositoryImpl(SimulatorDeviceBleDataSource());
    controller = _buildController(repository);
  });

  tearDown(() {
    controller.onClose();
    repository.onClose();
  });

  test(
      'text feedback requires confirmation, stores provenance, unknown text never learns',
      () async {
    await controller.connect(SimulatorDeviceBleDataSource.deviceId);
    await controller.submitText('yên tĩnh');
    await controller.submitText('không thích');
    expect(controller.candidate.value, false);
    expect((await repository.readLife()).events, 0);

    await controller.feedback(false, fromText: true);
    expect((await repository.readLife()).events, 1);
    expect((await repository.readMemories()).single.fromText, true);

    await controller.submitText('Tôi thích rừng');
    expect((await repository.readLife()).events, 1);
    await controller.submitText('yên tĩnh');
    expect(controller.animation.value, AnimationState.happy);

    await controller.forget();
    expect(await repository.readMemories(), isEmpty);
  });

  test('device errors become localized status messages', () async {
    await controller.connect('unknown device');
    expect(controller.connected.value, isFalse);
    expect(controller.message.value, LocaleKeys.device_errorDeviceNotFound.tr);

    await controller.connect(SimulatorDeviceBleDataSource.deviceId);
    await controller.feedback(true);
    expect(
      controller.message.value,
      LocaleKeys.device_errorNoPendingSuggestion.tr,
    );
    expect((await repository.readLife()).events, 0);
  });
}
