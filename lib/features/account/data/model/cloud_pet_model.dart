/// `POST /v1/pets` / `GET /v1/pets` item (contract draft §2).
class CloudPetModel {
  const CloudPetModel({
    required this.petId,
    required this.brainId,
    required this.deviceId,
    required this.lastGeneration,
    required this.boundAt,
  });

  /// Throws [FormatException] when a field is missing or has the wrong type.
  factory CloudPetModel.fromJson(Map<String, dynamic> json) {
    final petId = json['petId'];
    final brainId = json['brainId'];
    final deviceId = json['deviceId'];
    final lastGeneration = json['lastGeneration'];
    final boundAt = json['boundAt'];
    if (petId is! String ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(petId) ||
        brainId is! String ||
        brainId.isEmpty ||
        deviceId is! String ||
        deviceId.isEmpty ||
        lastGeneration is! int ||
        lastGeneration < 0 ||
        boundAt is! String) {
      throw const FormatException('Invalid pet');
    }
    return CloudPetModel(
      petId: petId,
      brainId: brainId,
      deviceId: deviceId,
      lastGeneration: lastGeneration,
      boundAt: DateTime.parse(boundAt),
    );
  }

  final String petId;
  final String brainId;
  final String deviceId;
  final int lastGeneration;
  final DateTime boundAt;
}
