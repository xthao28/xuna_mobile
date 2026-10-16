import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';

/// Device-reported expression, rendered locally; it never advances pet life.
/// Disconnected and reduced-motion views use a still image of the last state.
class HomePetScene extends StatelessWidget {
  const HomePetScene({
    super.key,
    required this.animation,
    required this.connected,
    this.background,
  });

  final AnimationState animation;
  final bool connected;
  final AppPetBackground? background;

  @override
  Widget build(BuildContext context) {
    final expression = switch (animation) {
      AnimationState.idle => AppPetExpression.idle,
      AnimationState.happy => AppPetExpression.happy,
      AnimationState.curious => AppPetExpression.curious,
      AnimationState.sleep => AppPetExpression.sleep,
    };
    return AppXunaPet(
      expression: expression,
      animated: connected,
      scene: true,
      background: background,
      fit: BoxFit.cover,
    );
  }
}
