import 'package:xuna_mobile/features/device/data/mapper/device_codes.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class DeviceStatusMapper
    extends BaseDataMapper<DeviceStatusModel, DeviceStatus> {
  @override
  DeviceStatus mapToEntity(DeviceStatusModel? data) {
    if (data == null) throw const FormatException('Missing device status');
    return DeviceStatus(
      animation: DeviceCodes.animationFromCode(data.animationCode),
      sequence: data.sequence,
    );
  }
}
