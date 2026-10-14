import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_entry.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Detail of a journal card with its evidence notes.
class HomeJournalEntrySheet extends StatelessWidget {
  const HomeJournalEntrySheet({
    super.key,
    required this.entry,
    required this.onTalk,
    required this.onClose,
  });

  static const _noteDot = 7.0;

  final HomeJournalEntry entry;
  final VoidCallback onTalk;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final learned = entry.kind == HomeJournalKind.learned;
    return AppSheetFrame(
      children: [
        Row(
          children: [
            AppTag(
              text: learned
                  ? LocaleKeys.home_tagLearned.tr
                  : LocaleKeys.home_tagMemory.tr,
              color: learned ? AppColors.xunaLime : AppColors.xunaLilac,
              style: AppTextStyle.font13Semi,
              outlined: false,
            ),
            const Spacer(),
            Text(entry.label, style: AppTextStyle.mono11Re),
          ],
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        Text(entry.title, style: AppTextStyle.display30, maxLines: 3),
        const SizedBox(height: AppDimens.paddingVerySmall),
        Text(entry.body, style: AppTextStyle.font15Re, maxLines: 5),
        const SizedBox(height: AppDimens.padding14),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding14,
            vertical: AppDimens.paddingSmall,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radius12),
            border: Border.all(
              color: AppColors.xunaInk,
              width: AppDimens.stroke2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.notesTitle, style: AppTextStyle.mono10Bo),
              const SizedBox(height: AppDimens.paddingVerySmall),
              for (final note in entry.notes)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.padding6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: AppDimens.padding6,
                          right: AppDimens.paddingVerySmall,
                        ),
                        width: _noteDot,
                        height: _noteDot,
                        color: AppColors.xunaSparkle,
                      ),
                      Expanded(
                        child: Text(
                          note,
                          style: AppTextStyle.font14Re,
                          maxLines: 4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.padding18),
        Row(
          children: [
            Expanded(
              child: AppBoxButton(
                label: LocaleKeys.dialog_close.tr,
                onPressed: onClose,
              ),
            ),
            const SizedBox(width: AppDimens.padding10),
            Expanded(
              flex: 3,
              child: AppBoxButton(
                label: LocaleKeys.home_detailTalk.tr,
                onPressed: onTalk,
                highlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
