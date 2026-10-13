import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';

/// Read-only projection of the device-owned life state.
class LifeSummary extends Equatable {
  const LifeSummary({
    this.activeSeconds = 0,
    this.events = 0,
    this.decisionId = 0,
    this.context = InteractionContext.quiet,
    this.action = AnimationState.idle,
    this.quietChoice = AnimationState.idle,
    this.playChoice = AnimationState.idle,
    this.canFeedback = false,
    this.memories = 0,
  });

  /// Active lifetime recorded by the device.
  final int activeSeconds;

  /// Total feedback events the device has learned from.
  final int events;

  /// Request ID of the latest suggestion; feedback refers to it.
  final int decisionId;

  /// Context of the latest suggestion.
  final InteractionContext context;

  /// Action chosen by the latest suggestion.
  final AnimationState action;

  /// Action the device currently prefers in each context.
  final AnimationState quietChoice;
  final AnimationState playChoice;

  /// Whether the latest suggestion can still receive feedback.
  final bool canFeedback;

  /// Number of retained memory episodes.
  final int memories;

  @override
  List<Object?> get props => [
        activeSeconds,
        events,
        decisionId,
        context,
        action,
        quietChoice,
        playChoice,
        canFeedback,
        memories,
      ];
}
