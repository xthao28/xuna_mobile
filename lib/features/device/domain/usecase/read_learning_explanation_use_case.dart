import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Null means firmware does not support the projection. Never teaches or retries.
class ReadLearningExplanationUseCase
    extends NoInputUseCase<LearningExplanation?> {
  const ReadLearningExplanationUseCase(this._repository);
  final DeviceRepository _repository;
  @override
  Future<LearningExplanation?> execute() => _repository.readExplanation();
}
