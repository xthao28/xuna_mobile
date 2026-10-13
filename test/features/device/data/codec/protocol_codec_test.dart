import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/codec/protocol_codec.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';

void main() {
  test(
      'wire command uses specified little-endian layout and rejects malformed input',
      () {
    final bytes = ProtocolCodec.encode(
      0x12345678,
      const DeviceCommandModel.animation(DeviceProtocol.animationHappy),
    );
    expect(bytes, [1, 1, 0x78, 0x56, 0x34, 0x12, 1, 0]);
    expect(ProtocolCodec.decodeCommand(bytes).$1, 0x12345678);
    for (final bad in [
      Uint8List(0),
      Uint8List.fromList([1, 1, 0, 0, 0, 0, 0, 0]),
      Uint8List.fromList([2, 1, 1, 0, 0, 0, 1, 0]),
      Uint8List.fromList([1, 1, 1, 0, 0, 0, 4, 0]),
    ]) {
      expect(() => ProtocolCodec.decodeCommand(bad), throwsFormatException);
    }
  });

  test('status validates version, size, enum and unsolicited correlation', () {
    final bytes = Uint8List(16)..[0] = 1;
    expect(
      ProtocolCodec.decodeStatus(bytes).animationCode,
      DeviceProtocol.animationIdle,
    );
    bytes[2] = 1;
    expect(() => ProtocolCodec.decodeStatus(bytes), throwsFormatException);
    bytes[1] = DeviceProtocol.statusResult;
    bytes[6] = DeviceProtocol.resultBusy;
    expect(ProtocolCodec.decodeStatus(bytes).resultCode, 5);
  });

  test('feedback correlation wire and capabilities validation', () {
    final feedback = ProtocolCodec.encode(
      7,
      const DeviceCommandModel.feedback(
        approved: true,
        source: DeviceProtocol.sourceText,
        target: 42,
      ),
    );
    expect(feedback, [1, 3, 7, 0, 0, 0, 1, 2, 42, 0, 0, 0]);
    final (requestId, decoded) = ProtocolCodec.decodeCommand(feedback);
    expect(requestId, 7);
    expect(decoded.target, 42);
    expect(
      () => ProtocolCodec.encode(
        8,
        const DeviceCommandModel.feedback(
          approved: true,
          source: DeviceProtocol.sourceNone,
          target: 42,
        ),
      ),
      throwsFormatException,
    );
    ProtocolCodec.validateCapabilities(
        Uint8List.fromList([1, 8, 15, 0, 15, 3, 0x60, 9]));
    expect(
      () => ProtocolCodec.validateCapabilities(
          Uint8List.fromList([2, 8, 15, 0, 15, 3, 0x60, 9])),
      throwsFormatException,
    );
    expect(
        () => ProtocolCodec.decodeLife(Uint8List(19)), throwsFormatException);
  });
}
