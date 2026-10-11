import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';

enum AnimationState { idle, happy }

class DeviceStatus {
  const DeviceStatus(this.animation, this.sequence);
  final AnimationState animation;
  final int sequence;
}

abstract class DeviceRepository extends BaseRepository {
  Stream<DeviceStatus> get statuses;
  Future<List<String>> scan();
  Future<DeviceStatus> connect(String id);
  Future<DeviceStatus> requestAnimation(AnimationState animation);
  Future<void> disconnect();
}

class RequestAnimation extends UseCase<AnimationState, DeviceStatus> {
  const RequestAnimation(this.repository);
  final DeviceRepository repository;
  @override
  Future<DeviceStatus> execute(AnimationState input) =>
      repository.requestAnimation(input);
}
