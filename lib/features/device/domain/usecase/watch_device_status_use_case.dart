import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class WatchDeviceStatusUseCase extends NoInputUseCase<Stream<DeviceStatus>> {
  const WatchDeviceStatusUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Stream<DeviceStatus> execute() => _repository.watchStatus();
}
