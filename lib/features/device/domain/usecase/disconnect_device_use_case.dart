import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class DisconnectDeviceUseCase extends NoInputUseCase<void> {
  const DisconnectDeviceUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<void> execute() => _repository.disconnect();
}
