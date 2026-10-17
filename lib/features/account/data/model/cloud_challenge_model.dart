import 'dart:convert';
import 'dart:typed_data';

/// `POST /v1/devices/challenges` response.
class CloudChallengeModel {
  const CloudChallengeModel({
    required this.challengeId,
    required this.nonce,
    required this.expiresAt,
  });

  /// Throws [FormatException] unless the nonce decodes to 32 bytes.
  factory CloudChallengeModel.fromJson(Map<String, dynamic> json) {
    final challengeId = json['challengeId'];
    final nonce = json['nonce'];
    final expiresAt = json['expiresAt'];
    if (challengeId is! String ||
        challengeId.length != 36 ||
        nonce is! String ||
        expiresAt is! String) {
      throw const FormatException('Invalid challenge');
    }
    final bytes = base64.decode(nonce);
    if (bytes.length != 32) throw const FormatException('Invalid nonce');
    return CloudChallengeModel(
      challengeId: challengeId,
      nonce: bytes,
      expiresAt: DateTime.parse(expiresAt),
    );
  }

  final String challengeId;
  final Uint8List nonce;
  final DateTime expiresAt;
}
