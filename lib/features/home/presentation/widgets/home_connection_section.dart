import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/presentation/extension/device_labels.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Simulator label, connection status, current animation, scan/connect and
/// direct animation requests.
class HomeConnectionSection extends StatelessWidget {
  const HomeConnectionSection({
    super.key,
    required this.isSimulator,
    required this.message,
    required this.isBusy,
    required this.connected,
    required this.animation,
    required this.devices,
    required this.onScan,
    required this.onConnect,
    required this.onAnimation,
    required this.onDisconnect,
  });

  static const animationLabelKey = Key('home.animationLabel');

  final bool isSimulator;
  final String message;
  final bool isBusy;
  final bool connected;
  final AnimationState animation;
  final List<String> devices;
  final VoidCallback onScan;
  final ValueChanged<String> onConnect;
  final ValueChanged<AnimationState> onAnimation;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final canCommand = connected && !isBusy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSimulator) ...[
          Text(
            LocaleKeys.home_simulatorBadge.tr,
            style: AppTextStyle.font14Bo.copyWith(color: AppColors.primaryCam1),
          ),
          Text(
            LocaleKeys.home_simulatorNote.tr,
            style: AppTextStyle.font14Re,
            maxLines: 3,
          ),
        ],
        UtilWidget.sizedBox16,
        Text(message, style: AppTextStyle.font14Re, maxLines: 3),
        if (isBusy) const LinearProgressIndicator(),
        UtilWidget.sizedBox16,
        Icon(_icon(animation), size: AppDimens.iconSize80),
        Center(
          child: Text(
            animation.label,
            key: animationLabelKey,
            style: AppTextStyle.font14Re,
          ),
        ),
        FilledButton(
          onPressed: connected || isBusy ? null : onScan,
          child: Text(
            isSimulator
                ? LocaleKeys.home_scanSimulator.tr
                : LocaleKeys.home_scan.tr,
          ),
        ),
        for (final device in devices)
          ListTile(
            title: Text(device, style: AppTextStyle.font14Re),
            trailing: const Icon(Icons.bluetooth),
            onTap: connected || isBusy ? null : () => onConnect(device),
          ),
        Wrap(
          spacing: AppDimens.paddingVerySmall,
          children: [
            for (final state in AnimationState.values)
              OutlinedButton(
                onPressed: canCommand ? () => onAnimation(state) : null,
                child: Text(state.label),
              ),
          ],
        ),
        Text(
          LocaleKeys.home_expiryNote.tr,
          style: AppTextStyle.font14Re,
          maxLines: 2,
        ),
        TextButton(
          onPressed: canCommand ? onDisconnect : null,
          child: Text(LocaleKeys.home_disconnect.tr),
        ),
      ],
    );
  }

  static IconData _icon(AnimationState state) => switch (state) {
        AnimationState.idle => Icons.sentiment_satisfied,
        AnimationState.happy => Icons.sentiment_very_satisfied,
        AnimationState.sleep => Icons.bedtime,
        AnimationState.curious => Icons.search,
      };
}
