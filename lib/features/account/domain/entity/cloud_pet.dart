import 'package:equatable/equatable.dart';

/// A pet bound to the signed-in owner on XUNA Cloud (`GET /v1/pets`).
///
/// A cloud record, not pet state: the device stays authoritative (AGENTS §6).
class CloudPet extends Equatable {
  const CloudPet({
    required this.petId,
    required this.brainId,
    required this.deviceId,
    required this.lastGeneration,
    required this.boundAt,
  });

  /// Device-issued PetId, 32 lowercase hex characters.
  final String petId;
  final String brainId;
  final String deviceId;

  /// Snapshot generation the device signed at the last bind.
  final int lastGeneration;
  final DateTime boundAt;

  @override
  List<Object?> get props =>
      [petId, brainId, deviceId, lastGeneration, boundAt];
}
