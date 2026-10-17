import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/account/domain/domain.src.dart';

import '../../../../helpers/fake_cloud.dart';

void main() {
  const petId = 'd945c77026fd4f4a8a899bbff4aeed86';

  test('streams trimmed text as deltas and sends nothing else', () async {
    final cloud = FakeCloud();
    final events = await StreamCloudReplyUseCase(cloud)
        .execute((petId: petId, text: '  chào  ')).toList();
    expect(events, const [CloudReplyDelta('Chào '), CloudReplyDelta('bạn!')]);
    expect(cloud.repliedTexts, ['chào']);
  });

  test('failures end with Unavailable after any received text', () async {
    final cloud = FakeCloud()
      ..replyDeltas = const ['Ch']
      ..replyError =
          const AccountException(AccountExceptionKind.providerUnavailable);
    final events = await StreamCloudReplyUseCase(cloud)
        .execute((petId: petId, text: 'chào')).toList();
    expect(events, const [
      CloudReplyDelta('Ch'),
      CloudReplyUnavailable(AccountExceptionKind.providerUnavailable),
    ]);
  });

  test('empty or over-long text is never sent', () async {
    final cloud = FakeCloud();
    for (final text in ['   ', 'x' * 501]) {
      final events = await StreamCloudReplyUseCase(cloud)
          .execute((petId: petId, text: text)).toList();
      expect(events,
          const [CloudReplyUnavailable(AccountExceptionKind.invalidInput)]);
    }
    expect(cloud.repliedTexts, isEmpty);
  });
}
