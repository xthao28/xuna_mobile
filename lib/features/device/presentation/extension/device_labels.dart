import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/generated/locales.g.dart';

extension AnimationStateLabel on AnimationState {
  String get label => switch (this) {
        AnimationState.idle => LocaleKeys.device_animationIdle.tr,
        AnimationState.happy => LocaleKeys.device_animationHappy.tr,
        AnimationState.sleep => LocaleKeys.device_animationSleep.tr,
        AnimationState.curious => LocaleKeys.device_animationCurious.tr,
      };
}

extension InteractionContextLabel on InteractionContext {
  String get label => switch (this) {
        InteractionContext.quiet => LocaleKeys.device_contextQuiet.tr,
        InteractionContext.play => LocaleKeys.device_contextPlay.tr,
      };
}
