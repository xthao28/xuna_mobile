import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';

enum LearningInteraction { quiet, play, greeting }

enum LearningDayPart { unknown, morning, afternoon, evening, night }

enum LearningReason {
  unavailable,
  highestEstimate,
  exploration,
  noEvidence,
  told
}

/// Device-confirmed projection. Masses are discounted evidence, not raw counts.
class LearningExplanation extends Equatable {
  const LearningExplanation(
      {required this.interaction,
      required this.dayPart,
      required this.action,
      required this.reason,
      required this.fine,
      required this.rated,
      required this.probability,
      required this.effectiveMass,
      required this.positive,
      required this.negative,
      required this.statedPositive,
      required this.statedNegative});
  final LearningInteraction interaction;
  final LearningDayPart dayPart;
  final AnimationState action;
  final LearningReason reason;
  final bool fine;
  final int rated;
  final double probability;
  final double effectiveMass;
  final double positive;
  final double negative;
  final double statedPositive;
  final double statedNegative;
  @override
  List<Object?> get props => [
        interaction,
        dayPart,
        action,
        reason,
        fine,
        rated,
        probability,
        effectiveMass,
        positive,
        negative,
        statedPositive,
        statedNegative
      ];
}
