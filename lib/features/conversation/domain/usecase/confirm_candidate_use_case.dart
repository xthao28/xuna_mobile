import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/candidate_event.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class ConfirmCandidateUseCase extends UseCase<CandidateEvent, void> {
  const ConfirmCandidateUseCase(this._repository);
  final DeviceRepository _repository;
  bool get supportsStatedPreference => _repository.supportsStatedPreference;

  @override
  Future<void> execute(CandidateEvent input) async {
    if (!input.requiresConfirmation || !input.isComplete) {
      throw const DeviceException(DeviceExceptionKind.rejected);
    }
    if (input.type == CandidateType.rateLastReaction) {
      final life = await _repository.readLife();
      if (!life.canFeedback) {
        throw const DeviceException(DeviceExceptionKind.noPendingSuggestion);
      }
      return _repository.sendFeedback(
          approved: input.polarity == PreferencePolarity.like,
          fromText: true,
          decisionId: life.decisionId);
    }
    if (input.type != CandidateType.statePreference ||
        !supportsStatedPreference) {
      throw const DeviceException(DeviceExceptionKind.unsupportedDevice);
    }
    return _repository.statePreference(
      likes: input.polarity == PreferencePolarity.like,
      contextKey: (input.context!.index << 4) | input.dayPart.index,
      action: input.action!,
    );
  }
}
