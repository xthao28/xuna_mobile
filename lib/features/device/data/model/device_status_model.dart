/// Decoded 16-byte status frame (protocol v1).
class DeviceStatusModel {
  const DeviceStatusModel({
    required this.kind,
    required this.requestId,
    required this.resultCode,
    required this.animationCode,
    required this.sequence,
  });

  /// `DeviceProtocol.status*`: snapshot, command result or state change.
  final int kind;

  /// Request ID of a command result; 0 for unsolicited statuses.
  final int requestId;
  final int resultCode;
  final int animationCode;
  final int sequence;
}
