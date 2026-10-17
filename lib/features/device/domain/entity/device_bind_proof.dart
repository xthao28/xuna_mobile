import 'package:equatable/equatable.dart';

/// Signed Identity V2 bind proof from the device (ECDSA P-256). The private
/// key never leaves the device; the backend verifies this signature.
class DeviceBindProof extends Equatable {
  const DeviceBindProof({
    required this.generation,
    required this.publicKey,
    required this.signature,
  });

  /// Snapshot generation inside the signed message.
  final int generation;

  /// 65-byte uncompressed SEC1 public key.
  final List<int> publicKey;

  /// 64-byte r||s signature.
  final List<int> signature;

  @override
  List<Object?> get props => [generation, publicKey, signature];
}
