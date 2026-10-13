import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Deletes the learned preference and memories on the device. The UI must
/// confirm first (AGENTS §6).
class ForgetMemoriesUseCase extends NoInputUseCase<void> {
  const ForgetMemoriesUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<void> execute() => _repository.forget();
}
