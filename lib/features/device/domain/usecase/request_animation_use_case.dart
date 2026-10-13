import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_status.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// Direct animation request. It invalidates any pending suggestion on the
/// device.
class RequestAnimationUseCase extends UseCase<AnimationState, DeviceStatus> {
  const RequestAnimationUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<DeviceStatus> execute(AnimationState input) =>
      _repository.requestAnimation(input);
}
