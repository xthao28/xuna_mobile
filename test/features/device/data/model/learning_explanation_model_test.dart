import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/model/learning_explanation_model.dart';
import 'package:xuna_mobile/features/device/data/mapper/learning_explanation_mapper.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';

void main() {
  Uint8List told() => Uint8List.fromList(
      [1, 20, 0, 0, 1, 4, 0, 0, 154, 0, 128, 0, 128, 0, 0, 0, 128, 0, 0, 0]);
  test('firmware Told fixture separates stated mass and maps learner indices',
      () {
    final entity = LearningExplanationMapper()
        .mapToEntity(LearningExplanationModel.decode(told()));
    expect(entity.reason, LearningReason.told);
    expect(entity.action, AnimationState.happy);
    expect(entity.statedPositive, 0.5);
    expect(entity.rated, 0);
    final curious = told()..[4] = 2;
    expect(
        LearningExplanationMapper()
            .mapToEntity(LearningExplanationModel.decode(curious))
            .action,
        AnimationState.curious);
  });
  test('rejects malformed frames instead of inventing an explanation', () {
    for (final index in [0, 1, 2, 3, 4, 5, 6]) {
      final bad = told()..[index] = 255;
      expect(() => LearningExplanationModel.decode(bad), throwsFormatException);
    }
    expect(() => LearningExplanationModel.decode(Uint8List(19)),
        throwsFormatException);
    final inconsistent = told()
      ..[16] = 255
      ..[17] = 255;
    expect(() => LearningExplanationModel.decode(inconsistent),
        throwsFormatException);
  });
}
