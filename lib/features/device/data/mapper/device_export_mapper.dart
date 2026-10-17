import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/device_export.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/learning_explanation.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';
import 'package:xuna_mobile/shared/mappers/mappers_src.dart';

/// Builds the `xuna.export.v1` payload. Enum values are explicit snake_case
/// strings (never `enum.index`/`name`); Q8.8 masses are exported as raw
/// integers so the hash does not depend on float formatting.
class DeviceExportMapper
    extends BaseEntityMapper<DeviceExport, Map<String, Object?>> {
  DeviceExportMapper({required this.appVersion});

  final String appVersion;

  @override
  Map<String, Object?> mapToData(DeviceExport entity) {
    final life = entity.life;
    final explanation = entity.explanation;
    return {
      'exportedAtUtc': entity.exportedAt.toUtc().toIso8601String(),
      'app': {'version': appVersion},
      'capabilities': {
        'statedPreference': entity.capabilities.statedPreference,
        'timeSync': entity.capabilities.timeSync,
        'identity': entity.capabilities.identity,
      },
      'identity': {
        'petId': entity.identity.petId,
        'origin': _origin(entity.identity.origin),
        'snapshotGeneration': entity.identity.snapshotGeneration,
      },
      'life': {
        'activeSeconds': life.activeSeconds,
        'feedbackCount': life.events,
        'decisionId': life.decisionId,
        'context': _context(life.context),
        'action': _action(life.action),
        'quietChoice': _action(life.quietChoice),
        'playChoice': _action(life.playChoice),
        'canFeedback': life.canFeedback,
        'memoryCount': life.memories,
      },
      'memories': [
        for (final episode in entity.memories)
          {
            'context': _context(episode.context),
            'action': _action(episode.action),
            'approved': episode.approved,
            'source': episode.fromText ? 'text' : 'button',
          },
      ],
      'explanation': explanation == null
          ? null
          : {
              'interaction': _interaction(explanation.interaction),
              'dayPart': _dayPart(explanation.dayPart),
              'action': _action(explanation.action),
              'reason': _reason(explanation.reason),
              'fine': explanation.fine,
              'rated': explanation.rated,
              'probabilityQ8': _q8(explanation.probability),
              'effectiveMassQ8': _q8(explanation.effectiveMass),
              'positiveQ8': _q8(explanation.positive),
              'negativeQ8': _q8(explanation.negative),
              'statedPositiveQ8': _q8(explanation.statedPositive),
              'statedNegativeQ8': _q8(explanation.statedNegative),
            },
    };
  }

  static int _q8(double value) => (value * 256).round();

  static String _origin(PetOrigin origin) => switch (origin) {
        PetOrigin.hatchedOnDevice => 'hatched_on_device',
        PetOrigin.hatchedViaApp => 'hatched_via_app',
        PetOrigin.migratedFromV1 => 'migrated_from_v1',
      };

  static String _context(InteractionContext context) => switch (context) {
        InteractionContext.quiet => 'quiet',
        InteractionContext.play => 'play',
      };

  static String _action(AnimationState action) => switch (action) {
        AnimationState.idle => 'idle',
        AnimationState.happy => 'happy',
        AnimationState.sleep => 'sleep',
        AnimationState.curious => 'curious',
      };

  static String _interaction(LearningInteraction interaction) =>
      switch (interaction) {
        LearningInteraction.quiet => 'quiet',
        LearningInteraction.play => 'play',
        LearningInteraction.greeting => 'greeting',
      };

  static String _dayPart(LearningDayPart part) => switch (part) {
        LearningDayPart.unknown => 'unknown',
        LearningDayPart.morning => 'morning',
        LearningDayPart.afternoon => 'afternoon',
        LearningDayPart.evening => 'evening',
        LearningDayPart.night => 'night',
      };

  static String _reason(LearningReason reason) => switch (reason) {
        LearningReason.unavailable => 'unavailable',
        LearningReason.highestEstimate => 'highest_estimate',
        LearningReason.exploration => 'exploration',
        LearningReason.noEvidence => 'no_evidence',
        LearningReason.told => 'told',
      };
}
