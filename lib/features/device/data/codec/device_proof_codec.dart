import 'dart:typed_data';

import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/model/device_proof_model.dart';

/// Identity V2 device proof frames (firmware `xuna/identity/DeviceProof.h`).
///
/// Request (40 B): ver=1, size=40, purpose, 0, requestId u32 LE (≠0),
/// nonce[32]. Response (141 B): ver=1, size=141, purpose, status, requestId,
/// generation u32 LE, publicKey[65], signature[64]. Every method throws
/// [FormatException] on an invalid argument or malformed value.
abstract final class DeviceProofCodec {
  static const requestLength = 40;
  static const responseLength = 141;
  static const nonceLength = 32;
  static const publicKeyLength = 65;
  static const signatureLength = 64;

  static Uint8List encodeBindRequest(int requestId, List<int> nonce) {
    if (requestId <= 0 || requestId > DeviceProtocol.maxRequestId) {
      throw const FormatException('Invalid proof request ID');
    }
    if (nonce.length != nonceLength || nonce.any((b) => b < 0 || b > 0xff)) {
      throw const FormatException('Nonce must be 32 bytes');
    }
    final bytes = Uint8List(requestLength)
      ..[0] = DeviceProtocol.version
      ..[1] = requestLength
      ..[2] = DeviceProtocol.proofPurposeBind
      ..setRange(8, requestLength, nonce);
    ByteData.sublistView(bytes).setUint32(4, requestId, Endian.little);
    return bytes;
  }

  static DeviceProofModel decodeResponse(Uint8List bytes) {
    if (bytes.length != responseLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] != responseLength ||
        bytes[3] > DeviceProtocol.proofStatusFailed) {
      throw const FormatException('Invalid device proof');
    }
    final data = ByteData.sublistView(bytes);
    final model = DeviceProofModel(
      purpose: bytes[2],
      status: bytes[3],
      requestId: data.getUint32(4, Endian.little),
      generation: data.getUint32(8, Endian.little),
      publicKey: Uint8List.fromList(bytes.sublist(12, 77)),
      signature: Uint8List.fromList(bytes.sublist(77, responseLength)),
    );
    final signed = model.signature.any((b) => b != 0);
    if (model.status == DeviceProtocol.proofStatusOk) {
      if (model.purpose != DeviceProtocol.proofPurposeBind ||
          model.publicKey[0] != 0x04 ||
          !signed) {
        throw const FormatException('Incomplete device proof');
      }
    } else if (signed) {
      throw const FormatException('Signature without an ok status');
    }
    return model;
  }
}
