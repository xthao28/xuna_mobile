import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class ReadLifeSummaryUseCase extends NoInputUseCase<LifeSummary> {
  const ReadLifeSummaryUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<LifeSummary> execute() => _repository.readLife();
}
