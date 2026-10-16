import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Growth journey placeholder. Stages arrive with M06, so the card is dimmed
/// and labeled "coming soon" instead of showing an invented level.
class HomeGrowthCard extends StatelessWidget {
  const HomeGrowthCard({super.key, required this.onTap});

  static const _dimmedOpacity = 0.45;

  /// Placeholder sprite heights, growing per stage.
  static const _stageHeights = [54.0, 62.0, 76.0];

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final names = [
      LocaleKeys.home_growthStage1.tr,
      LocaleKeys.home_growthStage2.tr,
      LocaleKeys.home_growthStage3.tr,
    ];
    return AppInkCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingSmall,
        AppDimens.paddingSmall,
        AppDimens.paddingSmall,
        AppDimens.padding14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.home_growthTitle.tr,
                  style: AppTextStyle.display17,
                  maxLines: 2,
                ),
              ),
              AppTag(
                text: LocaleKeys.home_comingSoon.tr,
                color: AppColors.xunaLilacSoft,
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingVerySmall),
          Opacity(
            opacity: _dimmedOpacity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var stage = 0; stage < names.length; stage++)
                  Expanded(
                    child: Column(
                      children: [
                        AppXunaPet(
                          height: _stageHeights[stage],
                        ),
                        const SizedBox(height: AppDimens.padding3),
                        Text(names[stage], style: AppTextStyle.mono9Bo),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
