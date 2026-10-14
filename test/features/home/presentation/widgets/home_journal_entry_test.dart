import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_entry.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

void main() {
  setUpAll(() {
    Get.addTranslations(AppTranslation.translations);
    Get.locale = const Locale('vi', 'VN');
  });

  const playLike = MemoryEpisode(
    context: InteractionContext.play,
    action: AnimationState.happy,
    approved: true,
    fromText: false,
  );
  const playDislike = MemoryEpisode(
    context: InteractionContext.play,
    action: AnimationState.curious,
    approved: false,
    fromText: true,
  );
  const quietLike = MemoryEpisode(
    context: InteractionContext.quiet,
    action: AnimationState.idle,
    approved: true,
    fromText: false,
  );

  test('memory entry states only what the device recorded', () {
    final entry = HomeJournalEntry.memory(playDislike, 2);
    expect(entry.kind, HomeJournalKind.memory);
    expect(entry.label, '#2');
    expect(entry.title, 'Bạn không thích XUNA tò mò khi chơi');
    expect(entry.body, 'Ghi lại từ tin nhắn bạn đã xác nhận.');
    expect(entry.notes, [
      'Ngữ cảnh: Chơi',
      'XUNA đã chọn: Tò mò',
      'Bạn: không thích',
      'Nguồn: tin nhắn bạn đã xác nhận',
    ]);
  });

  test('learned entry cites only episodes of its own context', () {
    final entry = HomeJournalEntry.learned(
      context: InteractionContext.play,
      life: const LifeSummary(events: 3, playChoice: AnimationState.happy),
      memories: const [playLike, quietLike, playDislike],
    );
    expect(entry.kind, HomeJournalKind.learned);
    expect(entry.title, 'Khi chơi, XUNA chọn vui');
    expect(entry.body, 'XUNA rút ra từ 3 phản hồi bạn đã gửi.');
    expect(
      entry.notes.first,
      'Trong 2 kỷ niệm gần nhất ở ngữ cảnh này: 1 thích, 1 không thích.',
    );
  });

  test('learned entry without feedback says it is the default choice', () {
    final entry = HomeJournalEntry.learned(
      context: InteractionContext.quiet,
      life: const LifeSummary(),
      memories: const [],
    );
    expect(entry.body, LocaleKeys.home_learnedBodyNone.tr);
    expect(entry.notes.first, LocaleKeys.home_detailEvidenceNone.tr);
  });

  test('pending entry shows the latest suggestion', () {
    final entry = HomeJournalEntry.pending(
      life: const LifeSummary(
        context: InteractionContext.quiet,
        action: AnimationState.sleep,
        canFeedback: true,
      ),
      memories: const [],
    );
    expect(entry.title, 'Khi yên tĩnh, XUNA chọn ngủ');
    expect(entry.body, LocaleKeys.home_pendingBody.tr);
  });
}
