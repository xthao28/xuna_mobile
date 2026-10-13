/// One 4-byte entry of a memory page (protocol v1).
class MemoryEpisodeModel {
  const MemoryEpisodeModel({
    required this.contextCode,
    required this.actionCode,
    required this.approved,
    required this.sourceCode,
  });

  final int contextCode;
  final int actionCode;
  final bool approved;

  /// `DeviceProtocol.sourceButton` or `DeviceProtocol.sourceText`.
  final int sourceCode;
}
