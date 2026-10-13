import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class ConnectDeviceUseCase extends UseCase<String, DeviceStatus> {
  const ConnectDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<DeviceStatus> execute(String input) => _repository.connect(input);
}
