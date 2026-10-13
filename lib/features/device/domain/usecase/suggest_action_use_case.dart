import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Lets the device choose an action for a context from its learned
/// preference. The choice can then receive feedback.
class SuggestActionUseCase extends UseCase<InteractionContext, DeviceStatus> {
  const SuggestActionUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<DeviceStatus> execute(InteractionContext input) =>
      _repository.suggest(input);
}
