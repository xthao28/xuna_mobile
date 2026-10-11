import 'package:xuna_mobile/core/domain/repository/base_repository.dart';
import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';

enum AnimationState { idle, happy, sleep, curious }

enum InteractionContext { quiet, play }

class DeviceStatus {
  const DeviceStatus(this.animation, this.sequence,
      {this.kind = 0, this.requestId = 0, this.result = 0});
  final AnimationState animation;
  final int sequence, kind, requestId, result;
}

class LifeSummary {
  const LifeSummary(
      {this.activeSeconds = 0,
      this.events = 0,
      this.decisionId = 0,
      this.context = InteractionContext.quiet,
      this.action = AnimationState.idle,
      this.quietChoice = AnimationState.idle,
      this.playChoice = AnimationState.idle,
      this.canFeedback = false,
      this.memories = 0});
  final int activeSeconds, events, decisionId, memories;
  final InteractionContext context;
  final AnimationState action, quietChoice, playChoice;
  final bool canFeedback;
}

class MemoryEpisode {
  const MemoryEpisode(this.context, this.action, this.approved, this.fromText);
  final InteractionContext context;
  final AnimationState action;
  final bool approved, fromText;
}

abstract class DeviceRepository extends BaseRepository {
  bool get simulated;
  Stream<DeviceStatus> get statuses;
  Future<List<String>> scan();
  Future<DeviceStatus> connect(String id);
  Future<DeviceStatus> requestAnimation(AnimationState animation);
  Future<DeviceStatus> suggest(InteractionContext context);
  Future<void> feedback(bool approved, {bool fromText = false});
  Future<LifeSummary> readLife();
  Future<List<MemoryEpisode>> readMemories();
  Future<void> forget();
  Future<void> disconnect();
}

class RequestAnimation extends UseCase<AnimationState, DeviceStatus> {
  const RequestAnimation(this.repository);
  final DeviceRepository repository;
  @override
  Future<DeviceStatus> execute(AnimationState input) =>
      repository.requestAnimation(input);
}
