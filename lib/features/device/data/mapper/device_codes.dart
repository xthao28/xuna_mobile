import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';

/// Explicit protocol v1 codes for domain enums. Never use `enum.index`:
/// reordering an enum must not change the wire format.
abstract final class DeviceCodes {
  static int animation(AnimationState state) => switch (state) {
        AnimationState.idle => DeviceProtocol.animationIdle,
        AnimationState.happy => DeviceProtocol.animationHappy,
        AnimationState.sleep => DeviceProtocol.animationSleep,
        AnimationState.curious => DeviceProtocol.animationCurious,
      };

  static AnimationState animationFromCode(int code) => switch (code) {
        DeviceProtocol.animationIdle => AnimationState.idle,
        DeviceProtocol.animationHappy => AnimationState.happy,
        DeviceProtocol.animationSleep => AnimationState.sleep,
        DeviceProtocol.animationCurious => AnimationState.curious,
        _ => throw FormatException('Unknown animation code $code'),
      };

  static int context(InteractionContext context) => switch (context) {
        InteractionContext.quiet => DeviceProtocol.contextQuiet,
        InteractionContext.play => DeviceProtocol.contextPlay,
      };

  static InteractionContext contextFromCode(int code) => switch (code) {
        DeviceProtocol.contextQuiet => InteractionContext.quiet,
        DeviceProtocol.contextPlay => InteractionContext.play,
        _ => throw FormatException('Unknown context code $code'),
      };

  static int feedbackSource({required bool fromText}) =>
      fromText ? DeviceProtocol.sourceText : DeviceProtocol.sourceButton;
}
