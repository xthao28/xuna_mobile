import 'dart:typed_data';

/// Identity V1 value (characteristic 7a6e000c). [originCode] 0 means the
/// device has no ready identity yet.
class PetIdentityModel {
  const PetIdentityModel({
    required this.petId,
    required this.originCode,
    required this.snapshotGeneration,
  });

  final Uint8List petId;
  final int originCode;
  final int snapshotGeneration;

  bool get ready => originCode != 0;
}
