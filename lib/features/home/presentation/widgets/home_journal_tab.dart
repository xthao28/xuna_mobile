import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_growth_card.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_card.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_entry.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// "Nhật ký" tab: the pending suggestion awaiting feedback, what XUNA has
/// learned per context, retained memories (newest first) and the growth
/// placeholder. All of it is read from the device.
class HomeJournalTab extends StatefulWidget {
  const HomeJournalTab({
    super.key,
    required this.connected,
    required this.isBusy,
    required this.life,
    required this.memories,
    required this.onFeedback,
    required this.onOpenEntry,
    required this.onForget,
    required this.onComingSoon,
  });

  final bool connected;
  final bool isBusy;
  final LifeSummary life;

  /// Oldest first, as read from the device.
  final List<MemoryEpisode> memories;
  final ValueChanged<bool> onFeedback;
  final ValueChanged<HomeJournalEntry> onOpenEntry;
  final VoidCallback onForget;
  final VoidCallback onComingSoon;

  @override
  State<HomeJournalTab> createState() => _HomeJournalTabState();
}

enum _Filter { all, memory, learned, growth }

class _HomeJournalTabState extends State<HomeJournalTab> {
  _Filter _filter = _Filter.all;

  bool _shows(_Filter kind) => _filter == _Filter.all || _filter == kind;

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
          title: LocaleKeys.home_journalTitle.tr,
          note: LocaleKeys.home_journalNote.tr,
          subtitle: LocaleKeys.home_journalSub.tr,
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: [
              for (final filter in _Filter.values)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimens.paddingVerySmall,
                  ),
                  child: AppPillButton(
                    label: _filterLabel(filter),
                    selected: _filter == filter,
                    pill: false,
                    onPressed: () => setState(() => _filter = filter),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.padding18),
        ..._timeline(),
      ],
    );
  }

  List<Widget> _timeline() {
    final cards = <Widget>[];
    if (!widget.connected) {
      cards.add(_note(LocaleKeys.home_journalOffline.tr));
    } else {
      final life = widget.life;
      if (life.canFeedback && _shows(_Filter.learned)) {
        cards.add(
          HomeJournalCard(
            entry: HomeJournalEntry.pending(
              life: life,
              memories: widget.memories,
            ),
            tag: LocaleKeys.home_tagPending.tr,
            onTap: null,
            actions: _feedbackActions(),
          ),
        );
      }
      if (_shows(_Filter.learned)) {
        for (final context in InteractionContext.values) {
          final entry = HomeJournalEntry.learned(
            context: context,
            life: life,
            memories: widget.memories,
          );
          cards.add(
            HomeJournalCard(
              entry: entry,
              onTap: () => widget.onOpenEntry(entry),
            ),
          );
        }
      }
      if (_shows(_Filter.memory)) {
        if (widget.memories.isEmpty) {
          cards.add(_note(LocaleKeys.home_journalEmpty.tr));
        }
        for (var index = widget.memories.length - 1; index >= 0; index--) {
          final entry =
              HomeJournalEntry.memory(widget.memories[index], index + 1);
          cards.add(
            HomeJournalCard(
              entry: entry,
              onTap: () => widget.onOpenEntry(entry),
            ),
          );
        }
      }
    }
    if (_shows(_Filter.growth)) {
      cards.add(HomeGrowthCard(onTap: widget.onComingSoon));
    }
    if (widget.connected && widget.memories.isNotEmpty) {
      cards.add(
        Center(
          child: TextButton(
            onPressed: widget.isBusy ? null : widget.onForget,
            child: Text(
              LocaleKeys.home_forget.tr,
              style: AppTextStyle.font14Semi.copyWith(
                color: AppColors.xunaInkMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      );
    }
    return [
      for (final card in cards)
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.padding18),
          child: card,
        ),
    ];
  }

  Widget _feedbackActions() {
    final enabled = !widget.isBusy;
    return Row(
      children: [
        for (final approved in [true, false]) ...[
          if (!approved) const SizedBox(width: AppDimens.paddingVerySmall),
          Expanded(
            child: AppInkCard(
              color: approved ? AppColors.xunaLime : AppColors.xunaCard,
              radius: AppDimens.radius9,
              shadow: 0,
              enabled: enabled,
              onTap: () => widget.onFeedback(approved),
              semanticLabel: approved
                  ? LocaleKeys.home_approve.tr
                  : LocaleKeys.home_reject.tr,
              child: SizedBox(
                height: AppDimens.padding40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      approved
                          ? Assets.ASSETS_ICONS_IC_THUMB_UP_SVG
                          : Assets.ASSETS_ICONS_IC_THUMB_DOWN_SVG,
                    ),
                    const SizedBox(width: AppDimens.paddingVerySmall),
                    Flexible(
                      child: Text(
                        approved
                            ? LocaleKeys.home_approve.tr
                            : LocaleKeys.home_reject.tr,
                        style: AppTextStyle.font14Semi,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _note(String text) => AppInkCard(
        shadow: 0,
        padding: const EdgeInsets.all(AppDimens.padding14),
        child: Text(text, style: AppTextStyle.font14Re, maxLines: 4),
      );

  static String _filterLabel(_Filter filter) => switch (filter) {
        _Filter.all => LocaleKeys.home_filterAll.tr,
        _Filter.memory => LocaleKeys.home_filterMemory.tr,
        _Filter.learned => LocaleKeys.home_filterLearned.tr,
        _Filter.growth => LocaleKeys.home_filterGrowth.tr,
      };
}
