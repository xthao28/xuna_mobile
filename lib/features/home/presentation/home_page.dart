import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_page.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/widgets.src.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Home shell: Nhà, Trò chuyện, Nhật ký and Thiết bị tabs over one device
/// connection. Tabs are dumb widgets; this page binds them to the controller.
class HomePage extends BaseGetPage<HomeController> {
  HomePage({super.key});

  @override
  bool get hasAppBar => false;

  static final _navItems = [
    AppNavItem(
      label: LocaleKeys.home_navHome.tr,
      iconAsset: Assets.ASSETS_ICONS_IC_NAV_HOME_SVG,
      activeIconAsset: Assets.ASSETS_ICONS_IC_NAV_HOME_ACTIVE_SVG,
    ),
    AppNavItem(
      label: LocaleKeys.home_navChat.tr,
      iconAsset: Assets.ASSETS_ICONS_IC_NAV_CHAT_SVG,
      activeIconAsset: Assets.ASSETS_ICONS_IC_NAV_CHAT_ACTIVE_SVG,
    ),
    AppNavItem(
      label: LocaleKeys.home_navJournal.tr,
      iconAsset: Assets.ASSETS_ICONS_IC_NAV_JOURNAL_SVG,
      activeIconAsset: Assets.ASSETS_ICONS_IC_NAV_JOURNAL_ACTIVE_SVG,
    ),
    AppNavItem(
      label: LocaleKeys.home_navDevice.tr,
      iconAsset: Assets.ASSETS_ICONS_IC_NAV_DEVICE_SVG,
      activeIconAsset: Assets.ASSETS_ICONS_IC_NAV_DEVICE_ACTIVE_SVG,
    ),
  ];

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.xunaPaper,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => IndexedStack(
            index: controller.tab.value.index,
            children: [
              _buildOverview(),
              _buildChat(),
              _buildJournal(),
              _buildDevice(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          items: _navItems,
          currentIndex: controller.tab.value.index,
          onSelected: (index) => controller.selectTab(HomeTab.values[index]),
        ),
      ),
    );
  }

  Widget _buildOverview() => Obx(
        () => HomeOverviewTab(
          isSimulator: controller.isSimulator,
          connected: controller.connected.value,
          isBusy: controller.isBusy,
          animation: controller.animation.value,
          latestMemory:
              controller.memories.isEmpty ? null : controller.memories.last,
          onConnection: () => controller.selectTab(HomeTab.device),
          onPoke: controller.poke,
          onTalk: () => controller.selectTab(HomeTab.chat),
          onJournal: () => controller.selectTab(HomeTab.journal),
          onComingSoon: controller.showComingSoon,
        ),
      );

  Widget _buildChat() => Obx(
        () => HomeChatTab(
          messages: controller.messages.toList(),
          connected: controller.connected.value,
          isBusy: controller.isBusy,
          candidate: controller.candidate.value,
          candidateReview: controller.candidateReview.value,
          onBack: () => controller.selectTab(HomeTab.home),
          onMenu: _openChatMenu,
          onSubmit: controller.submitText,
          onConfirmCandidate: (approved) =>
              controller.teachingCandidate.value != null
                  ? controller.confirmTeachingCandidate()
                  : controller.feedback(approved, fromText: true),
          onCancelCandidate: controller.cancelCandidate,
          onComingSoon: controller.showComingSoon,
        ),
      );

  Widget _buildJournal() => Obx(
        () => HomeJournalTab(
          connected: controller.connected.value,
          isBusy: controller.isBusy,
          life: controller.life.value,
          memories: controller.memories.toList(),
          onFeedback: controller.feedback,
          onOpenEntry: _openJournalEntry,
          onForget: controller.requestForget,
          onComingSoon: controller.showComingSoon,
        ),
      );

  Widget _buildDevice() => Obx(
        () => HomeDeviceTab(
          isSimulator: controller.isSimulator,
          connected: controller.connected.value,
          isBusy: controller.isBusy,
          message: controller.message.value,
          connectedDevice: controller.connectedDevice.value,
          devices: controller.devices.toList(),
          animation: controller.animation.value,
          onScan: controller.scan,
          onConnect: controller.connect,
          onDisconnect: controller.disconnect,
          onAnimation: controller.setAnimation,
          onInfo: _openDeviceInfo,
          onExport: controller.exportData,
          accountName: controller.account.value?.email ??
              controller.account.value?.displayName ??
              controller.account.value?.uid,
          onSignIn: controller.signIn,
          onSignOut: controller.signOut,
          onCheckCloud: controller.checkCloud,
          boundPetId: controller.boundPet?.petId,
          aiChatOn: controller.cloudChatReady,
          onBind: controller.bindPet,
          onConsents: _openConsents,
          onComingSoon: controller.showComingSoon,
        ),
      );

  Future<void> _openConsents() async {
    await controller.prepareConsents();
    if (controller.consentDraft.value == null) return;
    await nav.bottomSheet(
      Obx(() {
        final draft = controller.consentDraft.value;
        if (draft == null) return const SizedBox.shrink();
        return HomeConsentSheet(
          draft: draft,
          isBusy: controller.isBusy,
          onAggregateMetrics: (value) =>
              controller.editConsentDraft(aggregateMetrics: value),
          onExperienceEvents: (value) =>
              controller.editConsentDraft(experienceEvents: value),
          onConversationText: (value) =>
              controller.editConsentDraft(conversationText: value),
          onSave: controller.saveConsents,
          onClose: nav.back,
        );
      }),
      isScrollControlled: true,
    );
  }

  void _openChatMenu() => nav.bottomSheet(
        HomeChatMenuSheet(
          onRestart: () {
            nav.back();
            controller.restartChat();
          },
          onJournal: () {
            nav.back();
            controller.selectTab(HomeTab.journal);
          },
          onClose: nav.back,
        ),
        isScrollControlled: true,
      );

  void _openJournalEntry(HomeJournalEntry entry) => nav.bottomSheet(
        HomeJournalEntrySheet(
          entry: entry,
          onTalk: () {
            nav.back();
            controller.selectTab(HomeTab.chat);
          },
          onClose: nav.back,
        ),
        isScrollControlled: true,
      );

  void _openDeviceInfo() => nav.bottomSheet(
        HomeDeviceInfoSheet(
          onClose: nav.back,
          petId: controller.identity.value?.petId,
        ),
        isScrollControlled: true,
      );
}
