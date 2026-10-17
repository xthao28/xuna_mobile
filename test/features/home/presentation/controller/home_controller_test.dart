import 'dart:typed_data';
import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'package:xuna_mobile/features/device/domain/usecase/read_learning_explanation_use_case.dart';
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
import 'package:xuna_mobile/features/device/data/model/device_proof_model.dart';
import 'package:xuna_mobile/features/device/data/model/pet_identity_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export_result.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_export_repository.dart';
import 'package:xuna_mobile/features/device/domain/usecase/export_device_data_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/read_pet_identity_use_case.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

import '../../../../helpers/fake_cloud.dart';

class _RecordingExports implements DeviceExportRepository {
  final saved = <DeviceExport>[];
  @override
  Future<DeviceExportResult> save(DeviceExport export) async {
    saved.add(export);
    return const DeviceExportResult(
        location: '/exports/x.json', sha256: '0123456789abcdef');
  }
}

class _IdentityTransport extends SimulatorDeviceBleDataSource {
  @override
  bool get supportsIdentity => true;
  @override
  Future<PetIdentityModel?> readIdentity() async => PetIdentityModel(
        petId: Uint8List.fromList(List.generate(16, (i) => i)),
        originCode: 3,
        snapshotGeneration: 33,
      );
}

class _FakeAccounts extends FakeCloud {}

/// Identity V2 board: durable PetId and a device proof.
class _ProofTransport extends _IdentityTransport {
  int proofs = 0;

  @override
  bool get supportsDeviceProof => true;

  @override
  Future<DeviceProofModel> requestBindProof(Uint8List nonce) async {
    proofs++;
    return DeviceProofModel(
      purpose: 1,
      status: 2,
      requestId: 1,
      generation: 34,
      publicKey: Uint8List(65)..[0] = 4,
      signature: Uint8List(64)..[0] = 1,
    );
  }
}

HomeController _buildController(DeviceRepository repository,
        {DeviceExportRepository? exports, _FakeAccounts? accounts}) =>
    HomeController(
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
      readExplanation: ReadLearningExplanationUseCase(repository),
      forgetMemories: ForgetMemoriesUseCase(repository),
      readPetIdentity: ReadPetIdentityUseCase(repository),
      exportDeviceData:
          ExportDeviceDataUseCase(repository, exports ?? _RecordingExports()),
      watchAccount: WatchAccountUseCase(accounts ?? _FakeAccounts()),
      signInWithGoogle: SignInWithGoogleUseCase(accounts ?? _FakeAccounts()),
      signOut: SignOutUseCase(accounts ?? _FakeAccounts()),
      checkCloudConnection:
          CheckCloudConnectionUseCase(accounts ?? _FakeAccounts()),
      bindPetToCloud:
          BindPetToCloudUseCase(repository, accounts ?? _FakeAccounts()),
      readCloudPets: ReadCloudPetsUseCase(accounts ?? _FakeAccounts()),
      readConsents: ReadConsentsUseCase(accounts ?? _FakeAccounts()),
      updateConsents: UpdateConsentsUseCase(accounts ?? _FakeAccounts()),
      streamCloudReply: StreamCloudReplyUseCase(accounts ?? _FakeAccounts()),
      parseTextIntent: const ParseTextIntentUseCase(),
      extractCandidate: const ExtractCandidateUseCase(),
      confirmCandidate: ConfirmCandidateUseCase(repository),
    )..isTestMode = true;

class _ExplainedTransport extends SimulatorDeviceBleDataSource {
  @override
  Future<LearningExplanationModel?> readExplanation() async =>
      LearningExplanationModel.decode(Uint8List.fromList([
        1,
        20,
        0,
        0,
        1,
        4,
        0,
        0,
        154,
        0,
        128,
        0,
        128,
        0,
        0,
        0,
        128,
        0,
        0,
        0
      ]));
}

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

  final infoDialogs = <String>[];

  @override
  Future<void>? showInfoDialog({
    required String title,
    required String subtitle,
    required DialogIconType iconType,
    bool swapTitleAndIcon = false,
    String? confirmTitle,
    String? cancelTitle,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showConfirmButton = true,
    bool showCancelButton = true,
    bool barrierDismissible = false,
  }) {
    infoDialogs.add(subtitle);
    return null;
  }
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
  String lastReplyOf(HomeController view) => view.messages.last.text;

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

  test(
      'Why on a fake without evidence does not claim learning or send a command',
      () async {
    await controller.connect(SimulatorDeviceBleDataSource.deviceId);
    final before = (await repository.readLife()).events;
    await controller.submitText('tại sao');
    expect(lastReply(), LocaleKeys.home_replyExplanationUnavailable.tr);
    expect((await repository.readLife()).events, before);
  });

  test('Why grounds its reply in firmware Told fields', () async {
    Get.addTranslations(AppTranslation.translations);
    Get.updateLocale(const Locale('vi', 'VN'));
    final explained = DeviceRepositoryImpl(_ExplainedTransport());
    final view = _buildController(explained)..onInit();
    await view.connect(SimulatorDeviceBleDataSource.deviceId);
    await view.submitText('tại sao');
    expect(view.messages.last.text, contains('0.50'));
    expect(view.messages.last.text, contains(LocaleKeys.home_whyTold.tr));
    expect((await explained.readLife()).events, 0);
    view.onClose();
    explained.onClose();
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

  test('export refuses without a durable PetId and never writes a file',
      () async {
    final exports = _RecordingExports();
    final view = _buildController(repository, exports: exports)..onInit();
    await view.connect(SimulatorDeviceBleDataSource.deviceId);
    expect(view.identity.value, isNull);
    await view.exportData();
    expect(exports.saved, isEmpty);
    expect(view.message.value, LocaleKeys.device_errorIdentityUnavailable.tr);
    expect(navigator.infoDialogs, isEmpty);
    view.onClose();
  });

  test('export reads identity and device data, then reports the file',
      () async {
    final exports = _RecordingExports();
    final device = DeviceRepositoryImpl(_IdentityTransport());
    final view = _buildController(device, exports: exports)..onInit();
    await view.exportData();
    expect(exports.saved, isEmpty);
    await view.connect(SimulatorDeviceBleDataSource.deviceId);
    expect(view.identity.value?.petId, '000102030405060708090a0b0c0d0e0f');
    await view.exportData();
    final saved = exports.saved.single;
    expect(saved.identity.snapshotGeneration, 33);
    expect(saved.capabilities.identity, isTrue);
    expect(saved.life.events, 0);
    expect(navigator.infoDialogs, hasLength(1));
    await view.disconnect();
    expect(view.identity.value, isNull);
    view.onClose();
    device.onClose();
  });

  test('cloud account is optional: sign in, check cloud, sign out', () async {
    final accounts = _FakeAccounts();
    final view = _buildController(repository, accounts: accounts)..onInit();
    expect(view.account.value, isNull);
    await view.signIn();
    expect(view.account.value?.email, 'owner@example.com');
    await view.checkCloud();
    expect(accounts.cloudCalls, 1);
    expect(navigator.snackBars.last, LocaleKeys.account_cloudOk.tr);
    await view.signOut();
    expect(view.account.value, isNull);
    expect(navigator.snackBars.last, LocaleKeys.account_signedOutToast.tr);
    view.onClose();
  });

  test('account errors are localized and never block the pet', () async {
    final accounts = _FakeAccounts()
      ..signInError = const AccountException(AccountExceptionKind.cancelled);
    final view = _buildController(repository, accounts: accounts)..onInit();
    await view.signIn();
    expect(view.account.value, isNull);
    expect(navigator.snackBars.last, LocaleKeys.account_errorCancelled.tr);
    accounts
      ..signInError = null
      ..cloudError =
          const AccountException(AccountExceptionKind.cloudUnavailable);
    await view.signIn();
    await view.checkCloud();
    expect(
        navigator.snackBars.last, LocaleKeys.account_errorCloudUnavailable.tr);
    await view.connect(SimulatorDeviceBleDataSource.deviceId);
    expect(view.connected.value, isTrue);
    view.onClose();
  });

  group('XUNA Cloud bind, consent and AI chat', () {
    const petId = '000102030405060708090a0b0c0d0e0f';
    late _FakeAccounts accounts;
    late DeviceRepositoryImpl device;
    late HomeController view;

    setUp(() async {
      accounts = _FakeAccounts();
      device = DeviceRepositoryImpl(_ProofTransport());
      view = _buildController(device, accounts: accounts)..onInit();
      await view.signIn();
      await view.refreshCloud();
      await view.connect(SimulatorDeviceBleDataSource.deviceId);
    });

    tearDown(() {
      view.onClose();
      device.onClose();
    });

    Future<void> enableU3() async {
      await view.prepareConsents();
      view.editConsentDraft(conversationText: true);
      await view.saveConsents();
    }

    test('bind runs challenge → proof → bind and marks the pet bound',
        () async {
      expect(view.boundPet, isNull);
      await view.bindPet();
      expect(accounts.calls,
          containsAllInOrder(['challenge:$petId', 'bind:$petId:34']));
      expect(view.boundPet?.petId, petId);
      expect(navigator.snackBars.last, LocaleKeys.account_bindDone.tr);
    });

    test('bind errors are localized and leave the pet unbound', () async {
      accounts.bindError =
          const AccountException(AccountExceptionKind.petAlreadyBound);
      await view.bindPet();
      expect(view.boundPet, isNull);
      expect(
          navigator.snackBars.last, LocaleKeys.account_errorPetAlreadyBound.tr);
    });

    test('consents start off and are saved only on request', () async {
      await view.prepareConsents();
      expect(view.consentDraft.value, const ConsentSettings());
      view.editConsentDraft(conversationText: true);
      expect(accounts.consents.conversationText, isFalse);
      await view.saveConsents();
      expect(accounts.calls.last, 'updateConsents:0');
      expect(view.consents.value?.conversationText, isTrue);
      expect(navigator.snackBars.last, LocaleKeys.account_consentSaved.tr);
    });

    test('a consent conflict reloads the server state', () async {
      await view.prepareConsents();
      accounts.consentError =
          const AccountException(AccountExceptionKind.consentVersionConflict);
      view.editConsentDraft(aggregateMetrics: true);
      await view.saveConsents();
      await Future<void>.delayed(Duration.zero);
      expect(navigator.snackBars.last,
          LocaleKeys.account_errorConsentVersionConflict.tr);
      expect(view.consentDraft.value, accounts.consents);
    });

    test('free text uses the local template until bound with U3', () async {
      await view.submitText('kể chuyện đi');
      expect(lastReplyOf(view), LocaleKeys.home_replyUnknown.tr);
      await view.bindPet();
      await view.submitText('kể chuyện đi');
      expect(lastReplyOf(view), LocaleKeys.home_replyUnknown.tr);
      expect(accounts.repliedTexts, isEmpty);
      expect(view.cloudChatReady, isFalse);
    });

    test('with U3 the AI reply streams into one labeled bubble', () async {
      await view.bindPet();
      await enableU3();
      expect(view.cloudChatReady, isTrue);
      final before = view.messages.length;
      await view.submitText('  kể chuyện đi ');
      expect(accounts.repliedTexts, ['kể chuyện đi']);
      expect(view.messages.length, before + 2);
      expect(view.messages.last.text, 'Chào bạn!');
      expect(view.messages.last.generated, isTrue);
      expect(view.messages.last.fromXuna, isTrue);
      expect(view.isBusy, isFalse);
      // Display only: nothing reached the device.
      expect((await device.readLife()).events, 0);
    });

    test('teaching and device intents never go to the AI', () async {
      await view.bindPet();
      await enableU3();
      await view.submitText('chơi');
      await view.submitText('mình thích khi bạn tò mò');
      expect(accounts.repliedTexts, isEmpty);
    });

    test('provider outage falls back to the local template', () async {
      await view.bindPet();
      await enableU3();
      accounts
        ..replyDeltas = const []
        ..replyError =
            const AccountException(AccountExceptionKind.providerUnavailable);
      await view.submitText('kể chuyện đi');
      expect(lastReplyOf(view), LocaleKeys.home_replyUnknown.tr);
      expect(view.messages.last.generated, isFalse);
      expect(navigator.snackBars.last, isNot(contains('AI')));
    });

    test('sign-out clears cloud state and turns AI chat off', () async {
      await view.bindPet();
      await enableU3();
      await view.signOut();
      expect(view.cloudPets, isEmpty);
      expect(view.consents.value, isNull);
      expect(view.cloudChatReady, isFalse);
      expect(view.connected.value, isTrue);
    });
  });
}
