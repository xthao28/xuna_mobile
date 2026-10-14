import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Small settings shown in the design that are not built yet; each row says
/// so and explains it when tapped.
class HomeDeviceSettingsCard extends StatelessWidget {
  const HomeDeviceSettingsCard({super.key, required this.onComingSoon});

  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    final rows = [
      LocaleKeys.home_settingAutoConnect.tr,
      LocaleKeys.home_settingWake.tr,
    ];
    return AppInkCard(
      child: Column(
        children: [
          for (final row in rows)
            InkWell(
              onTap: onComingSoon,
              child: Container(
                constraints:
                    const BoxConstraints(minHeight: AppDimens.padding60),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.padding14,
                  vertical: AppDimens.padding10,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.xunaInk,
                      width: AppDimens.stroke2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(row,
                          style: AppTextStyle.font14Semi, maxLines: 2),
                    ),
                    AppTag(
                      text: LocaleKeys.home_comingSoon.tr,
                      color: AppColors.xunaLilacSoft,
                    ),
                    const SizedBox(width: AppDimens.paddingVerySmall),
                    const AppToggle(value: false, onChanged: null),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: onComingSoon,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding14,
                vertical: AppDimens.paddingSmall,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.home_settingAudio.tr,
                          style: AppTextStyle.font14Semi.copyWith(
                            color: AppColors.xunaInkDisabled,
                          ),
                        ),
                        const SizedBox(height: AppDimens.padding2),
                        Text(
                          LocaleKeys.home_settingAudioNote.tr,
                          style: AppTextStyle.font13Re.copyWith(
                            color: AppColors.xunaInkMuted,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  AppTag(
                    text: LocaleKeys.home_comingSoon.tr,
                    color: AppColors.xunaLilacSoft,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
