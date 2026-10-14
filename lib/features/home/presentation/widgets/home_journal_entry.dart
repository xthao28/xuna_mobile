import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/device/presentation/extension/device_labels.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

/// Kind of a journal card; also used by the journal filters.
enum HomeJournalKind { memory, learned }

/// Display text for one journal card, derived only from device data: the
/// learned preference per context and the retained feedback episodes. There
/// are no dates because the device does not record them in protocol v1.
class HomeJournalEntry extends Equatable {
  const HomeJournalEntry({
    required this.kind,
    required this.label,
    required this.title,
    required this.body,
    required this.notesTitle,
    required this.notes,
  });

  /// Preference the device currently uses in [context], with the recent
  /// episodes of that context as evidence.
  factory HomeJournalEntry.learned({
    required InteractionContext context,
    required LifeSummary life,
    required List<MemoryEpisode> memories,
  }) {
    final action = switch (context) {
      InteractionContext.quiet => life.quietChoice,
      InteractionContext.play => life.playChoice,
    };
    final evidence = memories.where((e) => e.context == context).toList();
    final liked = evidence.where((e) => e.approved).length;
    return HomeJournalEntry(
      kind: HomeJournalKind.learned,
      label: context.label.toUpperCase(),
      title: choiceTitle(context, action),
      body: life.events == 0
          ? LocaleKeys.home_learnedBodyNone.tr
          : LocaleKeys.home_learnedBody.trParams({'events': '${life.events}'}),
      notesTitle: LocaleKeys.home_detailWhy.tr,
      notes: [
        if (evidence.isEmpty)
          LocaleKeys.home_detailEvidenceNone.tr
        else
          LocaleKeys.home_detailEvidence.trParams({
            'count': '${evidence.length}',
            'liked': '$liked',
            'disliked': '${evidence.length - liked}',
          }),
        LocaleKeys.home_detailDeviceOwned.tr,
      ],
    );
  }

  /// The latest suggestion, still waiting for the owner's feedback.
  factory HomeJournalEntry.pending({
    required LifeSummary life,
    required List<MemoryEpisode> memories,
  }) {
    final learned = HomeJournalEntry.learned(
      context: life.context,
      life: life,
      memories: memories,
    );
    return HomeJournalEntry(
      kind: HomeJournalKind.learned,
      label: learned.label,
      title: choiceTitle(life.context, life.action),
      body: LocaleKeys.home_pendingBody.tr,
      notesTitle: learned.notesTitle,
      notes: learned.notes,
    );
  }

  /// One retained feedback episode; [index] counts from 1, oldest first.
  factory HomeJournalEntry.memory(MemoryEpisode episode, int index) {
    return HomeJournalEntry(
      kind: HomeJournalKind.memory,
      label: LocaleKeys.home_memoryIndex.trParams({'index': '$index'}),
      title: memoryTitle(episode),
      body: LocaleKeys.home_memoryBody.trParams({'source': source(episode)}),
      notesTitle: LocaleKeys.home_detailRecorded.tr,
      notes: [
        LocaleKeys.home_detailContext
            .trParams({'context': episode.context.label}),
        LocaleKeys.home_detailAction.trParams({'action': episode.action.label}),
        LocaleKeys.home_detailApproval.trParams({
          'approval': episode.approved
              ? LocaleKeys.home_memoryApproved.tr
              : LocaleKeys.home_memoryRejected.tr,
        }),
        LocaleKeys.home_detailSource.trParams({'source': source(episode)}),
      ],
    );
  }

  final HomeJournalKind kind;

  /// Short label beside the tag: the context or the episode number.
  final String label;
  final String title;
  final String body;
  final String notesTitle;
  final List<String> notes;

  static String choiceTitle(
    InteractionContext context,
    AnimationState action,
  ) =>
      LocaleKeys.home_choiceTitle.trParams({
        'context': context.label.toLowerCase(),
        'action': action.label.toLowerCase(),
      });

  static String memoryTitle(MemoryEpisode episode) => (episode.approved
              ? LocaleKeys.home_memoryTitleApproved
              : LocaleKeys.home_memoryTitleRejected)
          .trParams({
        'action': episode.action.label.toLowerCase(),
        'context': episode.context.label.toLowerCase(),
      });

  static String source(MemoryEpisode episode) => episode.fromText
      ? LocaleKeys.home_memorySourceText.tr
      : LocaleKeys.home_memorySourceButton.tr;

  @override
  List<Object?> get props => [kind, label, title, body, notesTitle, notes];
}
