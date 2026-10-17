import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/account/domain/entity/consent_settings.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// XUNA Cloud consent choices U1–U3 (D23). Every class is off by default;
/// nothing changes until the owner presses save.
class HomeConsentSheet extends StatelessWidget {
  const HomeConsentSheet({
    super.key,
    required this.draft,
    required this.isBusy,
    required this.onAggregateMetrics,
    required this.onExperienceEvents,
    required this.onConversationText,
    required this.onSave,
    required this.onClose,
  });

  final ConsentSettings draft;
  final bool isBusy;
  final ValueChanged<bool> onAggregateMetrics;
  final ValueChanged<bool> onExperienceEvents;
  final ValueChanged<bool> onConversationText;
  final VoidCallback onSave;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        LocaleKeys.account_consentU1Title.tr,
        LocaleKeys.account_consentU1Note.tr,
        draft.aggregateMetrics,
        onAggregateMetrics,
      ),
      (
        LocaleKeys.account_consentU2Title.tr,
        LocaleKeys.account_consentU2Note.tr,
        draft.experienceEvents,
        onExperienceEvents,
      ),
      (
        LocaleKeys.account_consentU3Title.tr,
        LocaleKeys.account_consentU3Note.tr,
        draft.conversationText,
        onConversationText,
      ),
    ];
    return AppSheetFrame(
      eyebrow: LocaleKeys.account_consentEyebrow.tr,
      title: LocaleKeys.account_consentTitle.tr,
      children: [
        Text(
          LocaleKeys.account_consentIntro.tr,
          style: AppTextStyle.font13Re.copyWith(color: AppColors.xunaInkSoft),
          maxLines: 4,
        ),
        const SizedBox(height: AppDimens.paddingSmall),
        AppInkCard(
          shadow: 0,
          child: Column(
            children: [
              for (final (title, note, value, onChanged) in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.padding14,
                    vertical: AppDimens.padding10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyle.font14Semi),
                            const SizedBox(height: AppDimens.padding2),
                            Text(
                              note,
                              style: AppTextStyle.font13Re.copyWith(
                                color: AppColors.xunaInkMuted,
                              ),
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingVerySmall),
                      Semantics(
                        label: title,
                        child: AppToggle(
                          value: value,
                          onChanged: isBusy ? null : onChanged,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        AppBoxButton(
          label: LocaleKeys.account_consentSave.tr,
          onPressed: isBusy ? null : onSave,
          highlighted: true,
        ),
        const SizedBox(height: AppDimens.padding10),
        AppBoxButton(label: LocaleKeys.dialog_close.tr, onPressed: onClose),
      ],
    );
  }
}
