import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export_result.dart';

/// Writes device exports to local storage only; no service is involved.
///
/// Throws [DeviceException] with [DeviceExceptionKind.exportFailed] when the
/// file cannot be written.
abstract interface class DeviceExportRepository {
  Future<DeviceExportResult> save(DeviceExport export);
}
