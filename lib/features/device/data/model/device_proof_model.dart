import 'dart:typed_data';

/// Identity V2 proof value (characteristic 7a6e000d READ, 141 bytes).
class DeviceProofModel {
  const DeviceProofModel({
    required this.purpose,
    required this.status,
    required this.requestId,
    required this.generation,
    required this.publicKey,
    required this.signature,
  });

  final int purpose;
  final int status;
  final int requestId;

  /// Snapshot generation the device signed; the backend checks the same value.
  final int generation;

  /// 65-byte uncompressed SEC1 P-256 point; all zero before a proof.
  final Uint8List publicKey;

  /// 64-byte r||s; all zero unless [status] is ok.
  final Uint8List signature;
}
