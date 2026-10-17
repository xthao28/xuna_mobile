import 'dart:convert';

import 'package:xuna_mobile/features/account/data/model/sse_event_model.dart';

/// Minimal `text/event-stream` decoder (WHATWG SSE subset the backend uses:
/// `event:` and `data:` fields, blank-line dispatch, `:` comments).
abstract final class SseCodec {
  /// Events without an `event:` field use this name, as in the standard.
  static const defaultEvent = 'message';

  static Stream<SseEventModel> decode(Stream<List<int>> bytes) async* {
    var event = '';
    final data = <String>[];
    await for (final line
        in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (data.isNotEmpty) {
          yield SseEventModel(
            event: event.isEmpty ? defaultEvent : event,
            data: data.join('\n'),
          );
        }
        event = '';
        data.clear();
        continue;
      }
      if (line.startsWith(':')) continue;
      final colon = line.indexOf(':');
      final field = colon < 0 ? line : line.substring(0, colon);
      var value = colon < 0 ? '' : line.substring(colon + 1);
      if (value.startsWith(' ')) value = value.substring(1);
      switch (field) {
        case 'event':
          event = value;
        case 'data':
          data.add(value);
      }
    }
    if (data.isNotEmpty) {
      throw const FormatException('Event stream ended inside an event');
    }
  }
}
