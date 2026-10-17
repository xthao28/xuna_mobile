import 'package:equatable/equatable.dart';

/// Where an export was written and the hash recorded inside it.
class DeviceExportResult extends Equatable {
  const DeviceExportResult({required this.location, required this.sha256});

  /// Local file path of the export.
  final String location;

  /// Lowercase hex SHA-256 of the exported payload.
  final String sha256;

  @override
  List<Object?> get props => [location, sha256];
}
