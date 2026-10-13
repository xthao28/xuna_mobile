import 'dart:async';

import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/text_intent.dart';
import 'package:xuna_mobile/features/conversation/domain/usecase/parse_text_intent_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
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
import 'package:xuna_mobile/features/device/presentation/extension/device_exception_message.dart';
import 'package:xuna_mobile/features/device/presentation/extension/device_labels.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';

class HomeController extends BaseGetxController {
  HomeController({
    required this.isSimulator,
    required ScanDevicesUseCase scanDevices,
    required ConnectDeviceUseCase connectDevice,
    required DisconnectDeviceUseCase disconnectDevice,
    required WatchDeviceStatusUseCase watchDeviceStatus,
    required RequestAnimationUseCase requestAnimation,
    required SuggestActionUseCase suggestAction,
    required SendFeedbackUseCase sendFeedback,
    required ReadLifeSummaryUseCase readLifeSummary,
    required ReadMemoriesUseCase readMemories,
    required ForgetMemoriesUseCase forgetMemories,
    required ParseTextIntentUseCase parseTextIntent,
  })  : _scanDevices = scanDevices,
        _connectDevice = connectDevice,
        _disconnectDevice = disconnectDevice,
        _watchDeviceStatus = watchDeviceStatus,
        _requestAnimation = requestAnimation,
        _suggestAction = suggestAction,
        _sendFeedback = sendFeedback,
        _readLifeSummary = readLifeSummary,
        _readMemories = readMemories,
        _forgetMemories = forgetMemories,
        _parseTextIntent = parseTextIntent;

  /// The development fake transport is in use; the page must label it.
  final bool isSimulator;

  final ScanDevicesUseCase _scanDevices;
  final ConnectDeviceUseCase _connectDevice;
  final DisconnectDeviceUseCase _disconnectDevice;
  final WatchDeviceStatusUseCase _watchDeviceStatus;
  final RequestAnimationUseCase _requestAnimation;
  final SuggestActionUseCase _suggestAction;
  final SendFeedbackUseCase _sendFeedback;
  final ReadLifeSummaryUseCase _readLifeSummary;
  final ReadMemoriesUseCase _readMemories;
  final ForgetMemoriesUseCase _forgetMemories;
  final ParseTextIntentUseCase _parseTextIntent;

  final devices = <String>[].obs;
  final connected = false.obs;
  final animation = AnimationState.idle.obs;
  final memories = <MemoryEpisode>[].obs;
  final life = const LifeSummary().obs;

  /// Connection status line, including device errors.
  final message = LocaleKeys.home_statusNotConnected.tr.obs;

  /// Conversation reply line.
  final reply = LocaleKeys.home_replyIntro.tr.obs;

  /// Text feedback awaiting confirmation: true approves, false rejects.
  final candidate = Rxn<bool>();

  StreamSubscription<DeviceStatus>? _statusSubscription;

  bool get isBusy => isLoading.value || isLoadingOverlay.value;

  @override
  void onInit() {
    super.onInit();
    _statusSubscription = _watchDeviceStatus.execute().listen(
      (status) {
        if (connected.value) animation.value = status.animation;
      },
      onError: (Object error) {
        connected.value = false;
        candidate.value = null;
        message.value = error is DeviceException
            ? error.localizedMessage
            : LocaleKeys.app_somethingWentWrong.tr;
      },
    );
  }

  Future<void> scan() => _run(() async {
        devices.assignAll(await _scanDevices.execute());
        message.value = devices.isEmpty
            ? LocaleKeys.home_statusNoDevice.tr
            : LocaleKeys.home_statusFound
                .trParams({'count': '${devices.length}'});
      });

  Future<void> connect(String deviceId) => _run(() async {
        final status = await _connectDevice.execute(deviceId);
        animation.value = status.animation;
        connected.value = true;
        candidate.value = null;
        await _refreshLife();
        message.value = isSimulator
            ? LocaleKeys.home_statusConnectedSimulator.tr
            : LocaleKeys.home_statusConnected.tr;
      });

  Future<void> setAnimation(AnimationState value) => _run(() async {
        if (!connected.value) return;
        candidate.value = null;
        animation.value = (await _requestAnimation.execute(value)).animation;
        await _refreshLife();
      });

  Future<void> suggest(InteractionContext context) => _run(() async {
        candidate.value = null;
        animation.value = (await _suggestAction.execute(context)).animation;
        await _refreshLife();
        final template = switch (context) {
          InteractionContext.quiet => LocaleKeys.home_replySuggestedQuiet,
          InteractionContext.play => LocaleKeys.home_replySuggestedPlay,
        };
        reply.value = template.trParams({'action': life.value.action.label});
      });

  Future<void> feedback(bool approved, {bool fromText = false}) =>
      _run(() async {
        await _sendFeedback.execute((approved: approved, fromText: fromText));
        candidate.value = null;
        await _refreshLife();
        reply.value = approved
            ? LocaleKeys.home_replyFeedbackApproved.tr
            : LocaleKeys.home_replyFeedbackRejected.tr;
      });

  /// Asks for confirmation before deleting memory and preference.
  void requestForget() {
    if (!connected.value || isBusy) return;
    nav.showConfirmDialog(
      title: LocaleKeys.home_forgetTitle.tr,
      subtitle: LocaleKeys.home_forgetMessage.tr,
      confirmTitle: LocaleKeys.home_forgetConfirm.tr,
      onConfirm: () => unawaited(forget()),
    );
  }

  Future<void> forget() => _run(() async {
        await _forgetMemories.execute();
        candidate.value = null;
        await _refreshLife();
        reply.value = LocaleKeys.home_replyForgotten.tr;
      });

  /// Local text V1. Feedback intents only become a candidate that the user
  /// must confirm; unknown text never teaches XUNA and is not stored.
  Future<void> submitText(String input) async {
    if (!connected.value) {
      reply.value = LocaleKeys.home_replyNeedConnection.tr;
      return;
    }
    final intent = _parseTextIntent.execute(input);
    switch (intent) {
      case TextIntent.play:
        await suggest(InteractionContext.play);
      case TextIntent.quiet:
        await suggest(InteractionContext.quiet);
      case TextIntent.approve:
      case TextIntent.reject:
        if (!life.value.canFeedback) {
          reply.value = LocaleKeys.home_replyNeedSuggestion.tr;
          return;
        }
        final approved = intent == TextIntent.approve;
        candidate.value = approved;
        final template = approved
            ? LocaleKeys.home_replyConfirmApproved
            : LocaleKeys.home_replyConfirmRejected;
        reply.value = template.trParams({'action': life.value.action.label});
      case TextIntent.unknown:
        reply.value = LocaleKeys.home_replyUnknown.tr;
    }
  }

  void cancelCandidate() => candidate.value = null;

  Future<void> disconnect() => _run(() async {
        await _disconnectDevice.execute();
        connected.value = false;
        candidate.value = null;
        message.value = LocaleKeys.home_statusDisconnected.tr;
      });

  @override
  void onClose() {
    _statusSubscription?.cancel();
    unawaited(_disconnectDevice.execute());
    super.onClose();
  }

  Future<void> _refreshLife() async {
    life.value = await _readLifeSummary.execute();
    memories.assignAll(await _readMemories.execute());
  }

  /// One device action at a time; device errors go to [message].
  Future<void> _run(Future<void> Function() action) async {
    if (isBusy) return;
    await buildState(
      action: action,
      showLoading: true,
      onError: _handleError,
    );
  }

  AppException? _handleError(AppException error) {
    if (error is! DeviceException) return error;
    message.value = error.localizedMessage;
    return null;
  }
}
