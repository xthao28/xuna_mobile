import 'dart:async';

import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/core/presentation/navigation/app_navigator.dart';
import 'package:xuna_mobile/core/presentation/navigation/snack_bar_type.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';
import 'package:xuna_mobile/features/account/presentation/presentation.src.dart';
import 'package:xuna_mobile/features/conversation/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/presentation/presentation.src.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/exceptions/base/app_exception.dart';

/// Bottom navigation destinations of the home shell.
enum HomeTab { home, chat, journal, device }

/// One line of the on-screen conversation. Kept in memory only: never
/// persisted or logged (AGENTS §6.4).
typedef HomeChatMessage = ({bool fromXuna, String text, DateTime at});

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
    required ReadLearningExplanationUseCase readExplanation,
    required ForgetMemoriesUseCase forgetMemories,
    required ReadPetIdentityUseCase readPetIdentity,
    required ExportDeviceDataUseCase exportDeviceData,
    required WatchAccountUseCase watchAccount,
    required SignInWithGoogleUseCase signInWithGoogle,
    required SignOutUseCase signOut,
    required CheckCloudConnectionUseCase checkCloudConnection,
    required ParseTextIntentUseCase parseTextIntent,
    required ExtractCandidateUseCase extractCandidate,
    required ConfirmCandidateUseCase confirmCandidate,
  })  : _scanDevices = scanDevices,
        _connectDevice = connectDevice,
        _disconnectDevice = disconnectDevice,
        _watchDeviceStatus = watchDeviceStatus,
        _requestAnimation = requestAnimation,
        _suggestAction = suggestAction,
        _sendFeedback = sendFeedback,
        _readLifeSummary = readLifeSummary,
        _readMemories = readMemories,
        _readExplanation = readExplanation,
        _forgetMemories = forgetMemories,
        _readPetIdentity = readPetIdentity,
        _exportDeviceData = exportDeviceData,
        _watchAccount = watchAccount,
        _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _checkCloudConnection = checkCloudConnection,
        _parseTextIntent = parseTextIntent,
        _extractCandidate = extractCandidate,
        _confirmCandidate = confirmCandidate;

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
  final ReadLearningExplanationUseCase _readExplanation;
  final ForgetMemoriesUseCase _forgetMemories;
  final ReadPetIdentityUseCase _readPetIdentity;
  final ExportDeviceDataUseCase _exportDeviceData;
  final WatchAccountUseCase _watchAccount;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final SignOutUseCase _signOut;
  final CheckCloudConnectionUseCase _checkCloudConnection;
  final ParseTextIntentUseCase _parseTextIntent;
  final ExtractCandidateUseCase _extractCandidate;
  final ConfirmCandidateUseCase _confirmCandidate;

  /// Oldest messages are dropped beyond this many lines.
  static const maxMessages = 40;

  final tab = HomeTab.home.obs;
  final devices = <String>[].obs;
  final connected = false.obs;
  final animation = AnimationState.idle.obs;
  final memories = <MemoryEpisode>[].obs;
  final life = const LifeSummary().obs;

  /// Connection status line, including device errors.
  final message = LocaleKeys.home_statusNotConnected.tr.obs;

  /// Device the app is connected to, for the device screen.
  final connectedDevice = RxnString();

  /// Durable device identity; null for old firmware or before hatching.
  final identity = Rxn<PetIdentity>();

  /// Optional cloud account (Firebase Auth); unrelated to pet authority.
  final account = Rxn<Account>();

  /// On-screen conversation, newest last.
  final messages = <HomeChatMessage>[].obs;

  /// Text feedback awaiting confirmation: true approves, false rejects.
  final candidate = Rxn<bool>();
  final teachingCandidate = Rxn<CandidateEvent>();
  final pendingContextCandidate = Rxn<CandidateEvent>();
  final candidateReview = RxnString();

  StreamSubscription<DeviceStatus>? _statusSubscription;
  StreamSubscription<Account?>? _accountSubscription;

  bool get isBusy => isLoading.value || isLoadingOverlay.value;

  @override
  void onInit() {
    super.onInit();
    _say(LocaleKeys.home_replyIntro.tr);
    _accountSubscription = _watchAccount.execute().listen(
          (value) => account.value = value,
          onError: (Object _) => account.value = null,
        );
    _statusSubscription = _watchDeviceStatus.execute().listen(
      (status) {
        if (connected.value) animation.value = status.animation;
      },
      onError: (Object error) {
        connected.value = false;
        connectedDevice.value = null;
        identity.value = null;
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
        connectedDevice.value = deviceId;
        candidate.value = null;
        await _refreshLife();
        identity.value = await _readPetIdentity.execute();
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
        _say(template.trParams({'action': life.value.action.label}));
      });

  Future<void> feedback(bool approved, {bool fromText = false}) =>
      _run(() async {
        await _sendFeedback.execute((approved: approved, fromText: fromText));
        candidate.value = null;
        await _refreshLife();
        _say(
          approved
              ? LocaleKeys.home_replyFeedbackApproved.tr
              : LocaleKeys.home_replyFeedbackRejected.tr,
        );
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
        _say(LocaleKeys.home_replyForgotten.tr);
      });

  /// Local text V1. Feedback intents only become a candidate that the user
  /// must confirm; unknown text never teaches XUNA and is not stored.
  Future<void> submitText(String input) async {
    final text = input.trim();
    if (text.isEmpty || isBusy) return;
    _append((fromXuna: false, text: text, at: DateTime.now()));
    if (!connected.value) {
      _say(LocaleKeys.home_replyNeedConnection.tr);
      return;
    }
    final extraction = _extractCandidate.execute(input);
    final pendingContext = pendingContextCandidate.value;
    if (pendingContext != null) {
      final context = _extractCandidate.resolveContext(input);
      if (context == null) {
        _say(LocaleKeys.home_replyNeedContext.tr);
        return;
      }
      pendingContextCandidate.value = null;
      _prepareCandidate(pendingContext.withContext(context));
      return;
    }
    if (extraction.outcome == ExtractionOutcome.needsContext) {
      pendingContextCandidate.value = extraction.candidate;
      _say(LocaleKeys.home_replyNeedContext.tr);
      return;
    }
    final event = extraction.candidate;
    if (event?.type == CandidateType.askWhy) {
      await _run(_sayExplanation);
      return;
    }
    if (event != null && event.requiresConfirmation) {
      if (event.type == CandidateType.statePreference &&
          !_confirmCandidate.supportsStatedPreference) {
        _say(LocaleKeys.home_replyStatedUnsupported.tr);
        return;
      }
      _prepareCandidate(event);
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
          _say(LocaleKeys.home_replyNeedSuggestion.tr);
          return;
        }
        final approved = intent == TextIntent.approve;
        candidate.value = approved;
        final template = approved
            ? LocaleKeys.home_replyConfirmApproved
            : LocaleKeys.home_replyConfirmRejected;
        _say(template.trParams({'action': life.value.action.label}));
      case TextIntent.unknown:
        _say(LocaleKeys.home_replyUnknown.tr);
    }
  }

  void cancelCandidate() {
    candidate.value = null;
    teachingCandidate.value = null;
    pendingContextCandidate.value = null;
    candidateReview.value = null;
  }

  Future<void> confirmTeachingCandidate() => _run(() async {
        final event = teachingCandidate.value;
        if (event == null) return;
        await _confirmCandidate.execute(event);
        teachingCandidate.value = null;
        candidate.value = null;
        candidateReview.value = null;
        await _refreshLife();
        await _sayExplanation();
      });

  Future<void> _sayExplanation() async {
    final explanation = await _readExplanation.execute();
    if (explanation == null ||
        explanation.reason == LearningReason.unavailable) {
      _say(LocaleKeys.home_replyExplanationUnavailable.tr);
      return;
    }
    final reason = switch (explanation.reason) {
      LearningReason.unavailable => LocaleKeys.home_replyExplanationUnavailable,
      LearningReason.highestEstimate => LocaleKeys.home_whyHighest,
      LearningReason.exploration => LocaleKeys.home_whyExplore,
      LearningReason.noEvidence => LocaleKeys.home_whyNoEvidence,
      LearningReason.told => LocaleKeys.home_whyTold,
    };
    final context = switch (explanation.interaction) {
      LearningInteraction.quiet => LocaleKeys.home_whyQuiet,
      LearningInteraction.play => LocaleKeys.home_whyPlay,
      LearningInteraction.greeting => LocaleKeys.home_whyGreeting,
    };
    final day = switch (explanation.dayPart) {
      LearningDayPart.unknown => LocaleKeys.home_whyUnknownTime,
      LearningDayPart.morning => LocaleKeys.home_whyMorning,
      LearningDayPart.afternoon => LocaleKeys.home_whyAfternoon,
      LearningDayPart.evening => LocaleKeys.home_whyEvening,
      LearningDayPart.night => LocaleKeys.home_whyNight,
    };
    _say(LocaleKeys.home_replyExplanation.trParams({
      'action': explanation.action.label,
      'context': context.tr,
      'day': day.tr,
      'reason': reason.tr,
      'rated': explanation.rated == 255 ? '≥255' : '${explanation.rated}',
      'statedPositive': explanation.statedPositive.toStringAsFixed(2),
      'statedNegative': explanation.statedNegative.toStringAsFixed(2),
    }));
  }

  void _prepareCandidate(CandidateEvent event) {
    teachingCandidate.value = event;
    candidate.value = event.polarity == PreferencePolarity.like;
    candidateReview.value = event.type == CandidateType.statePreference
        ? '${event.polarity!.name} | ${event.action!.label} | ${event.context!.name} | ${event.dayPart.name} | user_stated'
        : '${event.polarity!.name} | reaction ${life.value.decisionId} | user_feedback';
    _say(LocaleKeys.home_replyConfirmTeaching
        .trParams({'details': candidateReview.value!}));
  }

  void selectTab(HomeTab value) => tab.value = value;

  /// Touching XUNA on the home screen asks the device for a happy reaction.
  Future<void> poke() async {
    if (!connected.value) {
      _toast(LocaleKeys.home_pokeNeedConnection.tr);
      return;
    }
    await setAnimation(AnimationState.happy);
  }

  /// Clears the on-screen conversation; nothing is stored on the device.
  void restartChat() {
    candidate.value = null;
    messages.clear();
    _say(LocaleKeys.home_replyIntro.tr);
    _toast(LocaleKeys.home_chatRestarted.tr);
  }

  /// Feedback for a feature that is shown in the design but not built yet.
  void showComingSoon() => _toast(LocaleKeys.home_comingSoonToast.tr);

  /// Reads device data over BLE and writes a local `xuna.export.v1` file.
  /// Read-only: sends no command and teaches XUNA nothing.
  Future<void> exportData() => _run(() async {
        if (!connected.value) return;
        final result = await _exportDeviceData.execute();
        nav.showInfoDialog(
          title: LocaleKeys.home_exportDoneTitle.tr,
          subtitle: LocaleKeys.home_exportDoneMessage.trParams({
            'path': result.location,
            'hash': result.sha256.substring(0, 12),
          }),
          iconType: DialogIconType.success,
          showCancelButton: false,
          barrierDismissible: true,
        );
      });

  Future<void> signIn() => _run(() async {
        account.value = await _signInWithGoogle.execute();
      });

  Future<void> signOut() => _run(() async {
        await _signOut.execute();
        account.value = null;
        _toast(LocaleKeys.account_signedOutToast.tr);
      });

  /// Calls `GET /v1/me` with the Firebase token; sends no pet data.
  Future<void> checkCloud() => _run(() async {
        await _checkCloudConnection.execute();
        _toast(LocaleKeys.account_cloudOk.tr);
      });

  Future<void> disconnect() => _run(() async {
        await _disconnectDevice.execute();
        connected.value = false;
        connectedDevice.value = null;
        identity.value = null;
        candidate.value = null;
        message.value = LocaleKeys.home_statusDisconnected.tr;
      });

  @override
  void onClose() {
    _statusSubscription?.cancel();
    _accountSubscription?.cancel();
    unawaited(_disconnectDevice.execute());
    super.onClose();
  }

  Future<void> _refreshLife() async {
    life.value = await _readLifeSummary.execute();
    memories.assignAll(await _readMemories.execute());
  }

  void _say(String text) =>
      _append((fromXuna: true, text: text, at: DateTime.now()));

  void _append(HomeChatMessage line) {
    messages.add(line);
    if (messages.length > maxMessages) {
      messages.removeRange(0, messages.length - maxMessages);
    }
  }

  void _toast(String text) => nav.showSnackBar(text, type: SnackBarType.info);

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
    if (error is AccountException) {
      nav.showSnackBar(error.localizedMessage);
      return null;
    }
    if (error is! DeviceException) return error;
    message.value = error.localizedMessage;
    nav.showSnackBar(error.localizedMessage);
    return null;
  }
}
