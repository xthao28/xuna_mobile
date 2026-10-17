import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/device_proof_codec.dart';
import 'package:xuna_mobile/features/device/data/codec/protocol_codec.dart';
import 'package:xuna_mobile/features/device/data/data_source/device_proof_poller.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

import '../../../../helpers/device_matchers.dart';

final _nonce = List.generate(32, (i) => 0xc0 + i);

/// Capability value the Identity V2 board reported in the E2E run
/// (docs/roadmap/identity-v2-2026-10-17.md).
final _boardCapabilities =
    Uint8List.fromList([0x01, 0x08, 0xbf, 0x01, 0x0f, 0x03, 0x60, 0x09]);

/// 141-byte READ value laid out as firmware `ProofService::encode`, with the
/// firmware test's fake key (0x04, 0x10..) and signature (0xa0..0xdf).
Uint8List _response({
  int purpose = 1,
  int status = 2,
  int requestId = 0x01020304,
  int generation = 39,
  bool key = true,
  bool signature = true,
}) {
  final bytes = Uint8List(141)
    ..[0] = 1
    ..[1] = 141
    ..[2] = purpose
    ..[3] = status;
  ByteData.sublistView(bytes)
    ..setUint32(4, requestId, Endian.little)
    ..setUint32(8, generation, Endian.little);
  if (key) {
    bytes[12] = 0x04;
    for (var i = 1; i < 65; i++) {
      bytes[12 + i] = 0x10 + i;
    }
  }
  if (signature) {
    for (var i = 0; i < 64; i++) {
      bytes[77 + i] = 0xa0 + i;
    }
  }
  return bytes;
}

void main() {
  test('capability byte 3 bit 0 announces the device proof', () {
    expect(ProtocolCodec.supportsDeviceProof(_boardCapabilities), isTrue);
    expect(ProtocolCodec.supportsIdentity(_boardCapabilities), isTrue);
    final older = Uint8List.fromList(_boardCapabilities)..[3] = 0;
    expect(ProtocolCodec.supportsDeviceProof(older), isFalse);
  });

  test('encodes the 40-byte bind request', () {
    final bytes = DeviceProofCodec.encodeBindRequest(0x01020304, _nonce);
    expect(bytes.sublist(0, 8), [1, 40, 1, 0, 0x04, 0x03, 0x02, 0x01]);
    expect(bytes.sublist(8), _nonce);
  });

  test('rejects invalid request arguments', () {
    for (final call in [
      () => DeviceProofCodec.encodeBindRequest(0, _nonce),
      () => DeviceProofCodec.encodeBindRequest(0x100000000, _nonce),
      () => DeviceProofCodec.encodeBindRequest(1, _nonce.sublist(1)),
      () => DeviceProofCodec.encodeBindRequest(1, [..._nonce.sublist(1), 256]),
    ]) {
      expect(call, throwsFormatException);
    }
  });

  test('decodes a signed response', () {
    final model = DeviceProofCodec.decodeResponse(_response());
    expect(model.status, 2);
    expect(model.requestId, 0x01020304);
    expect(model.generation, 39);
    expect(model.publicKey, hasLength(65));
    expect(model.publicKey.first, 0x04);
    expect(model.signature.first, 0xa0);
    expect(model.signature.last, 0xdf);
  });

  test('decodes idle, pending and refusals without a signature', () {
    for (final status in [0, 1, 3, 4, 5]) {
      final model = DeviceProofCodec.decodeResponse(
          _response(status: status, key: false, signature: false));
      expect(model.status, status);
      expect(model.signature.every((b) => b == 0), isTrue);
    }
    // Failed signing still shows the key, never a signature.
    expect(
      DeviceProofCodec.decodeResponse(_response(status: 6, signature: false))
          .publicKey
          .first,
      0x04,
    );
  });

  test('rejects malformed responses', () {
    for (final bytes in [
      _response().sublist(0, 140),
      Uint8List.fromList([..._response(), 0]),
      _response()..[0] = 2,
      _response()..[1] = 140,
      _response(status: 7),
      _response(purpose: 2),
      _response(key: false),
      _response(signature: false),
      _response(status: 3),
    ]) {
      expect(
          () => DeviceProofCodec.decodeResponse(bytes), throwsFormatException);
    }
  });

  group('awaitDeviceProof', () {
    test('skips stale and pending values until its request is answered',
        () async {
      final values = [
        _response(status: 0, requestId: 0, key: false, signature: false),
        _response(status: 2, requestId: 7),
        _response(status: 1, key: false, signature: false),
        _response(),
      ];
      var reads = 0;
      final model = await awaitDeviceProof(
        requestId: 0x01020304,
        read: () async => values[reads++],
        isCurrent: () => true,
        interval: Duration.zero,
      );
      expect(reads, 4);
      expect(model.status, 2);
    });

    test('returns a refusal for the same request', () async {
      final model = await awaitDeviceProof(
        requestId: 0x01020304,
        read: () async => _response(status: 5, key: false, signature: false),
        isCurrent: () => true,
        interval: Duration.zero,
      );
      expect(model.status, 5);
    });

    test('times out instead of resending', () async {
      var reads = 0;
      await expectLater(
        awaitDeviceProof(
          requestId: 9,
          read: () async {
            reads++;
            return _response(status: 1, key: false, signature: false);
          },
          isCurrent: () => true,
          interval: const Duration(milliseconds: 5),
          timeout: const Duration(milliseconds: 30),
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(reads, greaterThan(1));
    });

    test('stops when the connection session changed', () async {
      await expectLater(
        awaitDeviceProof(
          requestId: 9,
          read: () async => _response(),
          isCurrent: () => false,
        ),
        throwsA(isDeviceException(DeviceExceptionKind.disconnected)),
      );
    });
  });
}
