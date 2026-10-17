import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/protocol_codec.dart';
import 'package:xuna_mobile/features/device/data/mapper/pet_identity_mapper.dart';
import 'package:xuna_mobile/features/device/domain/entity/pet_identity.dart';

/// Same bytes as firmware test_identity `identity_characteristic`.
final _firmwareFixture = Uint8List.fromList([
  1, 24, //
  0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0x46, 0xa7,
  0x88, 0xa9, 0xaa, 0xab, 0xac, 0xad, 0xae, 0xaf,
  3, 0, 0x04, 0x03, 0x02, 0x01,
]);

Uint8List _with(int index, int value) =>
    Uint8List.fromList(_firmwareFixture)..[index] = value;

void main() {
  test('decodes the firmware Identity V1 fixture', () {
    final model = ProtocolCodec.decodeIdentity(_firmwareFixture);
    expect(model.ready, isTrue);
    expect(model.snapshotGeneration, 0x01020304);
    expect(
      PetIdentityMapper().mapToEntity(model),
      const PetIdentity(
        petId: 'a0a1a2a3a4a546a788a9aaabacadaeaf',
        origin: PetOrigin.migratedFromV1,
        snapshotGeneration: 0x01020304,
      ),
    );
  });

  test('a device without identity sends only version and size', () {
    final empty = Uint8List(24)
      ..[0] = 1
      ..[1] = 24;
    final model = ProtocolCodec.decodeIdentity(empty);
    expect(model.ready, isFalse);
    expect(() => PetIdentityMapper().mapToEntity(model), throwsFormatException);
    final leaked = Uint8List.fromList(empty)..[20] = 1;
    expect(() => ProtocolCodec.decodeIdentity(leaked), throwsFormatException);
  });

  test('rejects malformed identity values', () {
    for (final bytes in [
      Uint8List.fromList(_firmwareFixture.sublist(0, 23)),
      _with(0, 2),
      _with(1, 20),
      _with(18, 4),
      _with(19, 1),
      _with(8, 0x16),
      _with(10, 0x48),
    ]) {
      expect(() => ProtocolCodec.decodeIdentity(bytes), throwsFormatException);
    }
  });

  test('capability bit 7 announces Identity V1', () {
    final caps = Uint8List.fromList([1, 8, 0xbf, 0, 15, 3, 0x60, 0x09]);
    expect(ProtocolCodec.supportsIdentity(caps), isTrue);
    expect(ProtocolCodec.supportsHatch(caps), isFalse);
    expect(ProtocolCodec.supportsIdentity(Uint8List.fromList(caps)..[2] = 0x3f),
        isFalse);
  });
}
