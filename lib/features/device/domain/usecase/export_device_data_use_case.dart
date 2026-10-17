import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export_result.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_export_repository.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Reads identity, life, memories and explanation from the connected device
/// and writes them as one local export (`xuna.export.v1`).
///
/// Requires a durable PetId: throws [DeviceExceptionKind.identityUnavailable]
/// for firmware without Identity V1, a device without a ready identity, or
/// the simulator. Reads only; never sends a command.
class ExportDeviceDataUseCase extends NoInputUseCase<DeviceExportResult> {
  const ExportDeviceDataUseCase(
    this._device,
    this._exports, {
    DateTime Function() now = DateTime.now,
  }) : _now = now;

  final DeviceRepository _device;
  final DeviceExportRepository _exports;
  final DateTime Function() _now;

  @override
  Future<DeviceExportResult> execute() async {
    final identity = await _device.readIdentity();
    if (identity == null) {
      throw const DeviceException(DeviceExceptionKind.identityUnavailable);
    }
    final life = await _device.readLife();
    final memories = await _device.readMemories();
    final explanation = await _device.readExplanation();
    return _exports.save(DeviceExport(
      exportedAt: _now().toUtc(),
      capabilities: (
        statedPreference: _device.supportsStatedPreference,
        timeSync: _device.supportsTimeSync,
        identity: _device.supportsIdentity,
      ),
      identity: identity,
      life: life,
      memories: memories,
      explanation: explanation,
    ));
  }
}
