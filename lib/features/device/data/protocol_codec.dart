import 'dart:typed_data';
import '../domain/device_repository.dart';

class ProtocolCodec {
  static const version = 1;
  static Uint8List command(int id, AnimationState animation) {
    if (id <= 0 || id > 0xffffffff) {
      throw const FormatException('Invalid request ID');
    }
    final bytes = Uint8List(8);
    bytes[0] = version;
    bytes[1] = 1;
    ByteData.sublistView(bytes).setUint32(2, id, Endian.little);
    bytes[6] = animation.index;
    return bytes;
  }

  static (int, AnimationState) parseCommand(Uint8List bytes) {
    if (bytes.length != 8 ||
        bytes[0] != version ||
        bytes[1] != 1 ||
        bytes[6] > 1 ||
        bytes[7] != 0) {
      throw const FormatException('Invalid command');
    }
    final id = ByteData.sublistView(bytes).getUint32(2, Endian.little);
    if (id == 0) throw const FormatException('Invalid request ID');
    return (id, AnimationState.values[bytes[6]]);
  }

  static DeviceStatus parseStatus(Uint8List bytes) {
    if (bytes.length != 16 ||
        bytes[0] != version ||
        bytes[1] > 2 ||
        bytes[6] > 7 ||
        bytes[7] > 1) {
      throw const FormatException('Invalid status');
    }
    final data = ByteData.sublistView(bytes);
    if (bytes[1] != 1 &&
        (data.getUint32(2, Endian.little) != 0 || bytes[6] != 0)) {
      throw const FormatException('Invalid unsolicited status');
    }
    if (bytes[6] != 0) throw StateError('Device error ${bytes[6]}');
    return DeviceStatus(
        AnimationState.values[bytes[7]], data.getUint32(8, Endian.little));
  }
}
