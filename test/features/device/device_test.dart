import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/protocol_codec.dart';
import 'package:xuna_mobile/features/device/data/simulator_device_repository.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';

void main() {
  test(
      'wire command uses specified little-endian layout and rejects malformed input',
      () {
    final bytes = ProtocolCodec.command(0x12345678, AnimationState.happy);
    expect(bytes, [1, 1, 0x78, 0x56, 0x34, 0x12, 1, 0]);
    expect(ProtocolCodec.parseCommand(bytes).$1, 0x12345678);
    for (final bad in [
      Uint8List(0),
      Uint8List.fromList([1, 1, 0, 0, 0, 0, 0, 0]),
      Uint8List.fromList([2, 1, 1, 0, 0, 0, 1, 0]),
      Uint8List.fromList([1, 1, 1, 0, 0, 0, 4, 0])
    ]) {
      expect(() => ProtocolCodec.parseCommand(bad), throwsFormatException);
    }
  });
  test('status validates version, size, enum and unsolicited correlation', () {
    final bytes = Uint8List(16)..[0] = 1;
    expect(ProtocolCodec.parseStatus(bytes).animation, AnimationState.idle);
    bytes[2] = 1;
    expect(() => ProtocolCodec.parseStatus(bytes), throwsFormatException);
    bytes[1] = 1;
    bytes[6] = 5;
    expect(ProtocolCodec.parseStatus(bytes).result, 5);
  });
  test(
      'fake requires connection; happy expires and reconnect reads current state',
      () async {
    final repo = SimulatorDeviceRepository(
        happyDuration: const Duration(milliseconds: 20));
    addTearDown(repo.onClose);
    await expectLater(
        repo.requestAnimation(AnimationState.happy), throwsStateError);
    expect(await repo.scan(), ['XUNA simulator']);
    await repo.connect('XUNA simulator');
    final useCase = RequestAnimation(repo);
    expect((await useCase.execute(AnimationState.happy)).animation,
        AnimationState.happy);
    await repo.disconnect();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
        (await repo.connect('XUNA simulator')).animation, AnimationState.idle);
    expect((await useCase.execute(AnimationState.idle)).sequence, 2);
  });
}
