import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Connection status of the device screen with scan, connect and disconnect.
class HomeDeviceStatusCard extends StatelessWidget {
  const HomeDeviceStatusCard({
    super.key,
    required this.isSimulator,
    required this.connected,
    required this.isBusy,
    required this.message,
    required this.connectedDevice,
    required this.devices,
    required this.onScan,
    required this.onConnect,
    required this.onDisconnect,
  });

  static const statusMessageKey = Key('home.deviceStatusMessage');

  final bool isSimulator;
  final bool connected;
  final bool isBusy;
  final String message;
  final String? connectedDevice;
  final List<String> devices;
  final VoidCallback onScan;
  final ValueChanged<String> onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final String title;
    if (connected) {
      title = LocaleKeys.home_statusTitleConnected.tr;
    } else if (isBusy) {
      title = LocaleKeys.home_statusTitleBusy.tr;
    } else {
      title = LocaleKeys.home_statusTitleOffline.tr;
    }
    return AppInkCard(
      padding: const EdgeInsets.all(AppDimens.padding14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.home_statusLabel.tr,
                      style: AppTextStyle.mono11Re,
                    ),
                    const SizedBox(height: AppDimens.paddingSmallest),
                    Text(title, style: AppTextStyle.display30),
                  ],
                ),
              ),
              AppTag(
                text: LocaleKeys.home_bleTag.tr,
                iconAsset: Assets.ASSETS_ICONS_IC_BLUETOOTH_SVG,
                color: connected ? AppColors.xunaLime : AppColors.xunaCard,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingSmall),
          AppKeyValueRow(
            label: LocaleKeys.home_rowDevice.tr,
            value: connectedDevice ?? LocaleKeys.home_noDevice.tr,
          ),
          AppKeyValueRow(
            label: LocaleKeys.home_rowStatus.tr,
            value: message,
            valueKey: statusMessageKey,
          ),
          AppKeyValueRow(
            label: LocaleKeys.home_rowMode.tr,
            value: isSimulator
                ? LocaleKeys.home_modeSimulator.tr
                : LocaleKeys.home_modeBoard.tr,
          ),
          const SizedBox(height: AppDimens.padding14),
          ..._buildConnectionActions(),
        ],
      ),
    );
  }

  List<Widget> _buildConnectionActions() {
    if (connected) {
      return [
        AppCtaButton(
          label: LocaleKeys.home_disconnect.tr,
          color: AppColors.xunaCard,
          onPressed: isBusy ? null : onDisconnect,
        ),
      ];
    }
    return [
      AppCtaButton(
        label: isSimulator
            ? LocaleKeys.home_scanSimulator.tr
            : LocaleKeys.home_scan.tr,
        onPressed: isBusy ? null : onScan,
      ),
      if (devices.isNotEmpty) ...[
        const SizedBox(height: AppDimens.padding14),
        Text(LocaleKeys.home_foundTitle.tr, style: AppTextStyle.mono11Re),
        for (final device in devices)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.paddingVerySmall),
            child: AppBoxButton(
              label: device,
              alignStart: true,
              onPressed: isBusy ? null : () => onConnect(device),
            ),
          ),
      ],
    ];
  }
}
