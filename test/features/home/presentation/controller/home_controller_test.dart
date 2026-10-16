import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/navigation/navigation_src.dart';
import 'package:xuna_mobile/features/conversation/domain/usecase/parse_text_intent_use_case.dart';
import 'package:xuna_mobile/features/conversation/domain/usecase/extract_candidate_use_case.dart';
import 'package:xuna_mobile/features/conversation/domain/usecase/confirm_candidate_use_case.dart';
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
      extractCandidate: const ExtractCandidateUseCase(),
      confirmCandidate: ConfirmCandidateUseCase(repository),
    )..isTestMode = true;

class _FakeNavigator extends Fake implements AppNavigator {
  final snackBars = <String>[];

  @override
  void showSnackBar<T>(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarType type = SnackBarType.failure,
    Alignment? align,
  }) =>
      snackBars.add(message);
}

void main() {
  late DeviceRepositoryImpl repository;
  late HomeController controller;
  late _FakeNavigator navigator;

  setUp(() {
    Get.testMode = true;
    navigator = Get.put<AppNavigator>(_FakeNavigator()) as _FakeNavigator;
    repository = DeviceRepositoryImpl(SimulatorDeviceBleDataSource());
    controller = _buildController(repository)..onInit();
  });

  tearDown(() {
    controller.onClose();
    repository.onClose();
    Get.reset();
  });

  String lastReply() => controller.messages.last.text;

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
    expect(lastReply(), LocaleKeys.home_replyUnknown.tr);
    expect(controller.messages[controller.messages.length - 2].fromXuna, false);
    expect((await repository.readLife()).events, 1);
    await controller.submitText('yên tĩnh');
    expect(controller.animation.value, AnimationState.happy);

    await controller.forget();
    expect(await repository.readMemories(), isEmpty);
    expect(lastReply(), LocaleKeys.home_replyForgotten.tr);
  });

  test('chat keeps a bounded in-memory transcript and restarts cleanly',
      () async {
    expect(controller.messages.single.text, LocaleKeys.home_replyIntro.tr);
    await controller.submitText('   ');
    expect(controller.messages, hasLength(1));

    for (var i = 0; i < HomeController.maxMessages; i++) {
      await controller.submitText('chơi');
    }
    expect(controller.messages, hasLength(HomeController.maxMessages));
    expect(lastReply(), LocaleKeys.home_replyNeedConnection.tr);

    controller.restartChat();
    expect(controller.messages.single.text, LocaleKeys.home_replyIntro.tr);
    expect(navigator.snackBars, [LocaleKeys.home_chatRestarted.tr]);
  });

  test('poke asks the connected device to be happy', () async {
    await controller.poke();
    expect(navigator.snackBars, [LocaleKeys.home_pokeNeedConnection.tr]);

    await controller.connect(SimulatorDeviceBleDataSource.deviceId);
    expect(controller.connectedDevice.value,
        SimulatorDeviceBleDataSource.deviceId);
    await controller.poke();
    expect(controller.animation.value, AnimationState.happy);

    controller.selectTab(HomeTab.device);
    expect(controller.tab.value, HomeTab.device);
    await controller.disconnect();
    expect(controller.connectedDevice.value, isNull);
  });

  test('stated preference waits for context and confirmation', () async {
    await controller.connect(SimulatorDeviceBleDataSource.deviceId);
    await controller
        .submitText('m\u00ecnh th\u00edch khi b\u1ea1n t\u00f2 m\u00f2');
    expect((await repository.readLife()).events, 0);
    await controller.submitText('khi ch\u01a1i');
    expect(controller.candidateReview.value, contains('user_stated'));
    expect((await repository.readLife()).events, 0);
    await controller.confirmTeachingCandidate();
    expect((await repository.readLife()).events, 1);
  });

  test('device errors become localized status messages', () async {
    await controller.connect('unknown device');
    expect(controller.connected.value, isFalse);
    expect(controller.message.value, LocaleKeys.device_errorDeviceNotFound.tr);
    expect(navigator.snackBars, [LocaleKeys.device_errorDeviceNotFound.tr]);

    await controller.connect(SimulatorDeviceBleDataSource.deviceId);
    await controller.feedback(true);
    expect(
      controller.message.value,
      LocaleKeys.device_errorNoPendingSuggestion.tr,
    );
    expect((await repository.readLife()).events, 0);
  });
}
