import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/mapper/device_codes.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';

void main() {
  test('maps enums to explicit wire codes and rejects unknown codes', () {
    expect(
      AnimationState.values.map(DeviceCodes.animation),
      [
        DeviceProtocol.animationIdle,
        DeviceProtocol.animationHappy,
        DeviceProtocol.animationSleep,
        DeviceProtocol.animationCurious,
      ],
    );
    for (final state in AnimationState.values) {
      expect(
          DeviceCodes.animationFromCode(DeviceCodes.animation(state)), state);
    }
    for (final context in InteractionContext.values) {
      expect(
          DeviceCodes.contextFromCode(DeviceCodes.context(context)), context);
    }
    expect(
        DeviceCodes.feedbackSource(fromText: true), DeviceProtocol.sourceText);
    expect(
      DeviceCodes.feedbackSource(fromText: false),
      DeviceProtocol.sourceButton,
    );
    expect(() => DeviceCodes.animationFromCode(4), throwsFormatException);
    expect(() => DeviceCodes.contextFromCode(2), throwsFormatException);
  });
}
