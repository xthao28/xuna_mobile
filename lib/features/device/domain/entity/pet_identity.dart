import 'package:equatable/equatable.dart';

/// How the device created this pet's identity.
enum PetOrigin { hatchedOnDevice, hatchedViaApp, migratedFromV1 }

/// Durable device-owned identity of the pet (Cloud gate b).
class PetIdentity extends Equatable {
  const PetIdentity({
    required this.petId,
    required this.origin,
    required this.snapshotGeneration,
  });

  /// 16-byte UUIDv4 as 32 lowercase hex characters, without dashes.
  final String petId;
  final PetOrigin origin;

  /// Generation of the last durable life snapshot; with [petId] it orders
  /// projections of the same pet.
  final int snapshotGeneration;

  @override
  List<Object?> get props => [petId, origin, snapshotGeneration];
}
