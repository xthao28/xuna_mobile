import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/features/device/data/codec/export_document_codec.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_export_local_data_source.dart';
import 'package:xuna_mobile/features/device/data/mapper/device_export_mapper.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export_result.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_export_repository.dart';

class DeviceExportRepositoryImpl extends BaseRepository
    implements DeviceExportRepository {
  DeviceExportRepositoryImpl(this._dataSource, {required String appVersion})
      : _mapper = DeviceExportMapper(appVersion: appVersion);

  final DeviceExportLocalDataSource _dataSource;
  final DeviceExportMapper _mapper;

  @override
  Future<DeviceExportResult> save(DeviceExport export) async {
    final payload = _mapper.mapToData(export);
    try {
      final location = await _dataSource.write(
        fileName(export),
        ExportDocumentCodec.encode(payload),
      );
      return DeviceExportResult(
        location: location,
        sha256: ExportDocumentCodec.hash(payload),
      );
    } catch (error) {
      throw DeviceException(
        DeviceExceptionKind.exportFailed,
        rootException: error,
      );
    }
  }

  /// `xuna-export-<petId>-<UTC yyyyMMddTHHmmssZ>.json`.
  static String fileName(DeviceExport export) {
    final at = export.exportedAt.toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    final stamp = '${at.year}${two(at.month)}${two(at.day)}'
        'T${two(at.hour)}${two(at.minute)}${two(at.second)}Z';
    return 'xuna-export-${export.identity.petId}-$stamp.json';
  }
}
