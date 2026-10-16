import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/candidate_event.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/day_part.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/preference_context.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

class ConfirmCandidateUseCase extends UseCase<CandidateEvent, void> {
  const ConfirmCandidateUseCase(this._repository);
  final DeviceRepository _repository;
  bool get supportsStatedPreference => _repository.supportsStatedPreference;

  @override
  Future<void> execute(CandidateEvent input) async {
    try {
      await _apply(input);
    } on DeviceException catch (error) {
      if (error.kind == DeviceExceptionKind.outcomeUnknown) {
        // Recover evidence only; do not retry an ambiguous write or claim success.
        try {
          await _repository.readExplanation();
        } catch (_) {/* Keep original error. */}
      }
      rethrow;
    }
  }

  Future<void> _apply(CandidateEvent input) async {
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
      contextKey: (switch (input.context!) {
                PreferenceContext.quiet => 0,
                PreferenceContext.play => 1,
                PreferenceContext.greeting => 2
              } <<
              4) |
          switch (input.dayPart) {
            DayPart.unknown => 0,
            DayPart.morning => 1,
            DayPart.afternoon => 2,
            DayPart.evening => 3,
            DayPart.night => 4
          },
      action: input.action!,
    );
  }
}
