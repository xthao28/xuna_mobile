/// Decoded 20-byte life characteristic (protocol v1).
class LifeSummaryModel {
  const LifeSummaryModel({
    required this.contextCode,
    required this.actionCode,
    required this.activeSeconds,
    required this.events,
    required this.decisionId,
    required this.quietChoiceCode,
    required this.playChoiceCode,
    required this.canFeedback,
    required this.memoryCount,
  });

  final int contextCode;
  final int actionCode;
  final int activeSeconds;
  final int events;
  final int decisionId;
  final int quietChoiceCode;
  final int playChoiceCode;
  final bool canFeedback;
  final int memoryCount;
}
