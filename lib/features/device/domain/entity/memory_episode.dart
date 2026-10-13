import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';

/// One confirmed feedback episode retained by the device.
class MemoryEpisode extends Equatable {
  const MemoryEpisode({
    required this.context,
    required this.action,
    required this.approved,
    required this.fromText,
  });

  final InteractionContext context;
  final AnimationState action;
  final bool approved;

  /// True when the feedback came from a confirmed text intent rather than the
  /// feedback button.
  final bool fromText;

  @override
  List<Object?> get props => [context, action, approved, fromText];
}
