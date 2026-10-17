import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/presentation/extension/device_labels.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_account_card.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_board_illustration.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_device_settings_card.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_device_status_card.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// "Thiết bị" tab: connection status and actions, direct expression
/// requests, device info and settings that are not built yet.
class HomeDeviceTab extends StatelessWidget {
  const HomeDeviceTab({
    super.key,
    required this.isSimulator,
    required this.connected,
    required this.isBusy,
    required this.message,
    required this.connectedDevice,
    required this.devices,
    required this.animation,
    required this.onScan,
    required this.onConnect,
    required this.onDisconnect,
    required this.onAnimation,
    required this.onInfo,
    required this.onExport,
    required this.accountName,
    required this.onSignIn,
    required this.onSignOut,
    required this.onCheckCloud,
    required this.onComingSoon,
  });

  final bool isSimulator;
  final bool connected;
  final bool isBusy;

  /// Latest connection status or device error.
  final String message;
  final String? connectedDevice;
  final List<String> devices;
  final AnimationState animation;
  final VoidCallback onScan;
  final ValueChanged<String> onConnect;
  final VoidCallback onDisconnect;
  final ValueChanged<AnimationState> onAnimation;
  final VoidCallback onInfo;

  /// Writes a local JSON export of device data; read-only.
  final VoidCallback onExport;

  /// Signed-in account label, or null when signed out.
  final String? accountName;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onCheckCloud;
  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.padding18,
        AppDimens.padding30,
        AppDimens.padding18,
        AppDimens.padding24,
      ),
      children: [
        AppDisplayHeading(
          title: LocaleKeys.home_deviceTitle.tr,
          note: LocaleKeys.home_deviceNote.tr,
          subtitle: LocaleKeys.home_deviceSub.tr,
        ),
        if (isSimulator) ...[
          const SizedBox(height: AppDimens.paddingSmall),
          AppInkCard(
            color: AppColors.xunaLime,
            shadow: 0,
            padding: const EdgeInsets.all(AppDimens.paddingSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.home_simulatorBadge.tr,
                  style: AppTextStyle.mono10Bo,
                ),
                Text(
                  LocaleKeys.home_simulatorNote.tr,
                  style: AppTextStyle.font13Re,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimens.defaultPadding),
        HomeBoardIllustration(
          animation: animation,
          connected: connected,
          isBusy: isBusy,
          statusColor: _statusColor(),
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        HomeDeviceStatusCard(
          isSimulator: isSimulator,
          connected: connected,
          isBusy: isBusy,
          message: message,
          connectedDevice: connectedDevice,
          devices: devices,
          onScan: onScan,
          onConnect: onConnect,
          onDisconnect: onDisconnect,
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        _buildExpressions(),
        const SizedBox(height: AppDimens.defaultPadding),
        Row(
          children: [
            Expanded(
              child: _tile(
                iconAsset: Assets.ASSETS_ICONS_IC_SUN_SVG,
                value: LocaleKeys.home_comingSoon.tr,
                label: LocaleKeys.home_brightness.tr,
                color: AppColors.xunaLime,
                enabled: false,
                onTap: onComingSoon,
              ),
            ),
            const SizedBox(width: AppDimens.paddingSmall),
            Expanded(
              child: _tile(
                iconAsset: Assets.ASSETS_ICONS_IC_CHIP_SVG,
                value: LocaleKeys.home_infoValue.tr,
                label: LocaleKeys.home_info.tr,
                color: AppColors.xunaLilacSoft,
                enabled: true,
                onTap: onInfo,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        AppBoxButton(
          label: LocaleKeys.home_exportButton.tr,
          onPressed: connected && !isBusy ? onExport : null,
        ),
        const SizedBox(height: AppDimens.padding6),
        Text(
          LocaleKeys.home_exportNote.tr,
          style: AppTextStyle.font13Re.copyWith(color: AppColors.xunaInkMuted),
          maxLines: 3,
        ),
        const SizedBox(height: AppDimens.padding22),
        HomeAccountCard(
          accountName: accountName,
          isBusy: isBusy,
          onSignIn: onSignIn,
          onSignOut: onSignOut,
          onCheckCloud: onCheckCloud,
        ),
        const SizedBox(height: AppDimens.padding22),
        Text(LocaleKeys.home_settingsTitle.tr, style: AppTextStyle.display19),
        const SizedBox(height: AppDimens.paddingVerySmall),
        HomeDeviceSettingsCard(onComingSoon: onComingSoon),
      ],
    );
  }

  Widget _buildExpressions() {
    final enabled = connected && !isBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(LocaleKeys.home_expressionsTitle.tr,
            style: AppTextStyle.display19),
        const SizedBox(height: AppDimens.paddingVerySmall),
        Wrap(
          spacing: AppDimens.paddingVerySmall,
          runSpacing: AppDimens.paddingVerySmall,
          children: [
            for (final state in AnimationState.values)
              AppPillButton(
                label: state.label,
                selected: connected && state == animation,
                onPressed: enabled ? () => onAnimation(state) : null,
              ),
          ],
        ),
        const SizedBox(height: AppDimens.padding6),
        Text(
          LocaleKeys.home_expiryNote.tr,
          style: AppTextStyle.font13Re.copyWith(color: AppColors.xunaInkMuted),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _tile({
    required String iconAsset,
    required String value,
    required String label,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
  }) =>
      Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AppInkCard(
          color: color,
          onTap: onTap,
          semanticLabel: label,
          padding: const EdgeInsets.all(AppDimens.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(iconAsset, width: AppDimens.padding25),
              const SizedBox(height: AppDimens.padding10),
              Text(value, style: AppTextStyle.display30),
              const SizedBox(height: AppDimens.paddingSmallest),
              Text(label, style: AppTextStyle.font13Semi),
            ],
          ),
        ),
      );

  Color _statusColor() {
    if (connected) return AppColors.xunaOnline;
    if (isBusy) return AppColors.xunaConnecting;
    return AppColors.xunaOffline;
  }
}
