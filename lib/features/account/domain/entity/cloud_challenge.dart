import 'package:equatable/equatable.dart';

/// Single-use backend challenge the device signs to prove it holds its key.
class CloudChallenge extends Equatable {
  const CloudChallenge({
    required this.challengeId,
    required this.nonce,
    required this.expiresAt,
  });

  final String challengeId;

  /// 32 random bytes chosen by the backend.
  final List<int> nonce;
  final DateTime expiresAt;

  @override
  List<Object?> get props => [challengeId, nonce, expiresAt];
}
