import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_entry.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Journal card: kind tag, label, title, body and a pixel illustration.
/// Optional [actions] are shown below (pending suggestion feedback).
class HomeJournalCard extends StatelessWidget {
  const HomeJournalCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.tag,
    this.actions,
  });

  static const _imageWidth = 96.0;
  static const _imageHeight = 80.0;

  final HomeJournalEntry entry;
  final VoidCallback? onTap;

  /// Overrides the kind tag text (used for the pending suggestion).
  final String? tag;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final learned = entry.kind == HomeJournalKind.learned;
    final extra = actions;
    return AppInkCard(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingSmall,
        AppDimens.paddingSmall,
        AppDimens.paddingSmall,
        AppDimens.padding14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppTag(
                      text: tag ??
                          (learned
                              ? LocaleKeys.home_tagLearned.tr
                              : LocaleKeys.home_tagMemory.tr),
                      color: learned ? AppColors.xunaLime : AppColors.xunaLilac,
                      style: AppTextStyle.font13Semi,
                      iconAsset: learned
                          ? Assets.ASSETS_ICONS_IC_LEARN_SVG
                          : Assets.ASSETS_ICONS_IC_MEMORY_SVG,
                      outlined: false,
                    ),
                    const Spacer(),
                    Text(entry.label, style: AppTextStyle.mono11Re),
                  ],
                ),
                const SizedBox(height: AppDimens.padding10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: AppTextStyle.font17Ex,
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppDimens.padding5),
                          Text(
                            entry.body,
                            style: AppTextStyle.font13Re,
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.padding10),
                    Container(
                      width: _imageWidth,
                      height: _imageHeight,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimens.radius4),
                        border: Border.all(
                          color: AppColors.xunaInk,
                          width: AppDimens.stroke2,
                        ),
                      ),
                      child: AppXunaPet(
                        background: AppPetBackground.garden,
                        expression: learned
                            ? AppPetExpression.curious
                            : AppPetExpression.idle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: AppDimens.paddingSmall),
            extra,
          ],
        ],
      ),
    );
  }
}
