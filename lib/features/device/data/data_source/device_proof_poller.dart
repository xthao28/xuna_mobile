import 'dart:async';
import 'dart:typed_data';

import 'package:xuna_mobile/features/device/data/codec/device_proof_codec.dart';
import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/model/device_proof_model.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

/// Reads the Identity V2 proof value until the device has answered
/// [requestId]: the firmware signs in its main loop (~74 ms on the board), so
/// the first READ is usually still pending or shows the previous value.
///
/// Throws [TimeoutException] after [timeout] (the request is not resent),
/// [DeviceException] `disconnected` once [isCurrent] turns false, and
/// [FormatException] for a malformed value.
Future<DeviceProofModel> awaitDeviceProof({
  required int requestId,
  required Future<Uint8List> Function() read,
  required bool Function() isCurrent,
  Duration interval = const Duration(milliseconds: 150),
  Duration timeout = const Duration(seconds: 5),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    if (!isCurrent()) {
      throw const DeviceException(DeviceExceptionKind.disconnected);
    }
    final model = DeviceProofCodec.decodeResponse(await read());
    if (model.requestId == requestId &&
        model.status != DeviceProtocol.proofStatusPending &&
        model.status != DeviceProtocol.proofStatusIdle) {
      return model;
    }
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Device proof $requestId not answered');
    }
    await Future<void>.delayed(interval);
  }
}
