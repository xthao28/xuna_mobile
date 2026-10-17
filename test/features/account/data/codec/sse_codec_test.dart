import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/account/data/codec/sse_codec.dart';

Stream<List<int>> _chunks(List<String> parts) =>
    Stream.fromIterable(parts.map(utf8.encode));

void main() {
  test('decodes backend events split across chunks, UTF-8 intact', () async {
    // Same framing as backend `conversation/api/routes.py::_sse`.
    final events = await SseCodec.decode(_chunks([
      'event: delta\ndata: {"text": "Ch',
      'ào"}\n\n: keep-alive\n\nevent: finished\n',
      'data: {"provider": "echo"}\n\n',
    ])).toList();
    expect(events.map((e) => e.event), ['delta', 'finished']);
    expect(jsonDecode(events.first.data), {'text': 'Chào'});
  });

  test('joins multi-line data and defaults the event name', () async {
    final events =
        await SseCodec.decode(_chunks(['data: a\ndata:b\r\n\r\n'])).toList();
    expect(events.single.event, SseCodec.defaultEvent);
    expect(events.single.data, 'a\nb');
  });

  test('a stream cut inside an event is malformed', () async {
    await expectLater(
      SseCodec.decode(_chunks(['event: delta\ndata: {"text": "x"}'])).toList(),
      throwsFormatException,
    );
  });
}
