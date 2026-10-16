import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';

/// A protocol v1 command before a request ID is assigned.
class DeviceCommandModel {
  const DeviceCommandModel({
    required this.opcode,
    required this.argument,
    this.source = DeviceProtocol.sourceNone,
    this.target = 0,
  });

  const DeviceCommandModel.animation(int animationCode)
      : this(opcode: DeviceProtocol.opcodeAnimation, argument: animationCode);

  const DeviceCommandModel.suggest(int contextCode)
      : this(opcode: DeviceProtocol.opcodeSuggest, argument: contextCode);

  /// [target] is the request ID of the rated suggestion.
  const DeviceCommandModel.feedback({
    required bool approved,
    required int source,
    required int target,
  }) : this(
          opcode: DeviceProtocol.opcodeFeedback,
          argument: approved ? 1 : 0,
          source: source,
          target: target,
        );

  const DeviceCommandModel.forget()
      : this(opcode: DeviceProtocol.opcodeForget, argument: 0);

  const DeviceCommandModel.statedPreference(
      {required bool likes, required int contextKey, required int action})
      : this(
            opcode: DeviceProtocol.opcodeStatedPreference,
            argument: likes ? 1 : 0,
            source: DeviceProtocol.sourceText,
            target: (action << 8) | contextKey);

  final int opcode;
  final int argument;
  final int source;
  final int target;
}
