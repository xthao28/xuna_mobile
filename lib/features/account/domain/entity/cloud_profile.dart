import 'package:equatable/equatable.dart';

/// The backend's view of the signed-in owner (`GET /v1/me`).
class CloudProfile extends Equatable {
  const CloudProfile({required this.userId});

  /// XUNA `userId` (never the Firebase uid).
  final String userId;

  @override
  List<Object?> get props => [userId];
}
