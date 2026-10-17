/// One Server-Sent Event: `event:` name and the joined `data:` lines.
class SseEventModel {
  const SseEventModel({required this.event, required this.data});

  final String event;
  final String data;
}
