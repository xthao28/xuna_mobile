import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/presentation/extension/device_labels.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_section_header.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';

/// Lets XUNA choose for a context, collects explicit feedback and shows the
/// learned preference with its recent evidence.
class HomeChoiceSection extends StatelessWidget {
  const HomeChoiceSection({
    super.key,
    required this.enabled,
    required this.life,
    required this.memories,
    required this.onSuggest,
    required this.onFeedback,
  });

  final bool enabled;
  final LifeSummary life;
  final List<MemoryEpisode> memories;
  final ValueChanged<InteractionContext> onSuggest;
  final ValueChanged<bool> onFeedback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: LocaleKeys.home_choiceTitle.tr,
          note: LocaleKeys.home_choiceNote.tr,
        ),
        Wrap(
          spacing: AppDimens.paddingVerySmall,
          children: [
            for (final interactionContext in InteractionContext.values)
              FilledButton(
                onPressed: enabled ? () => onSuggest(interactionContext) : null,
                child: Text(interactionContext.label),
              ),
          ],
        ),
        Wrap(
          spacing: AppDimens.paddingVerySmall,
          children: [
            for (final approved in [true, false])
              OutlinedButton(
                onPressed: enabled && life.canFeedback
                    ? () => onFeedback(approved)
                    : null,
                child: Text(
                  approved
                      ? LocaleKeys.home_approve.tr
                      : LocaleKeys.home_reject.tr,
                ),
              ),
          ],
        ),
        Text(
          LocaleKeys.home_preferenceLine.trParams({
            'quiet': life.quietChoice.label,
            'play': life.playChoice.label,
          }),
          style: AppTextStyle.font14Re,
          maxLines: 2,
        ),
        Text(
          LocaleKeys.home_statsLine.trParams({
            'events': '${life.events}',
            'memories': '${life.memories}',
            'seconds': '${life.activeSeconds}',
          }),
          style: AppTextStyle.font14Re,
          maxLines: 2,
        ),
        for (final episode in memories.reversed)
          Text(
            _describe(episode),
            style: AppTextStyle.font14Re,
            maxLines: 2,
          ),
      ],
    );
  }

  static String _describe(MemoryEpisode episode) =>
      LocaleKeys.home_memoryRow.trParams({
        'context': episode.context.label,
        'action': episode.action.label,
        'approval': episode.approved
            ? LocaleKeys.home_memoryApproved.tr
            : LocaleKeys.home_memoryRejected.tr,
        'source': episode.fromText
            ? LocaleKeys.home_memorySourceText.tr
            : LocaleKeys.home_memorySourceButton.tr,
      });
}
