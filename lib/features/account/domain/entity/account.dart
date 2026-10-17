import 'package:equatable/equatable.dart';

/// Owner signed in with Firebase Auth. Not pet state: the device stays
/// authoritative for the pet (AGENTS §6).
class Account extends Equatable {
  const Account({required this.uid, this.email, this.displayName});

  /// Firebase user ID; the backend maps it to its own `userId`.
  final String uid;
  final String? email;
  final String? displayName;

  @override
  List<Object?> get props => [uid, email, displayName];
}
