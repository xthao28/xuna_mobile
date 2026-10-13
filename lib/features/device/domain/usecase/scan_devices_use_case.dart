import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class ScanDevicesUseCase extends NoInputUseCase<List<String>> {
  const ScanDevicesUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<List<String>> execute() => _repository.scan();
}
