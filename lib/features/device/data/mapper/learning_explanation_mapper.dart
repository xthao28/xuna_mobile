import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

class LearningExplanationMapper
    extends BaseDataMapper<LearningExplanationModel, LearningExplanation> {
  @override
  LearningExplanation mapToEntity(LearningExplanationModel? data) {
    if (data == null) throw const FormatException('Missing explanation');
    final bytes = data.bytes;
    return LearningExplanation(
        interaction: switch (bytes[2]) {
          0 => LearningInteraction.quiet,
          1 => LearningInteraction.play,
          2 => LearningInteraction.greeting,
          _ => throw const FormatException('context')
        },
        dayPart: switch (bytes[3]) {
          0 => LearningDayPart.unknown,
          1 => LearningDayPart.morning,
          2 => LearningDayPart.afternoon,
          3 => LearningDayPart.evening,
          4 => LearningDayPart.night,
          _ => throw const FormatException('day part')
        },
        action: switch (bytes[4]) {
          0 => AnimationState.idle,
          1 => AnimationState.happy,
          2 => AnimationState.curious,
          _ => throw const FormatException('action')
        },
        reason: switch (bytes[5]) {
          0 => LearningReason.unavailable,
          1 => LearningReason.highestEstimate,
          2 => LearningReason.exploration,
          3 => LearningReason.noEvidence,
          4 => LearningReason.told,
          _ => throw const FormatException('reason')
        },
        fine: bytes[6] == 1,
        rated: bytes[7],
        probability: data.number(8),
        effectiveMass: data.number(10),
        positive: data.number(12),
        negative: data.number(14),
        statedPositive: data.number(16),
        statedNegative: data.number(18));
  }
}
