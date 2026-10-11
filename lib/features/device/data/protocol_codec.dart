import 'dart:typed_data';
import '../domain/device_repository.dart';

class ProtocolCodec {
  static const version = 1;
  static Uint8List command(int id, AnimationState animation) =>
      encode(id, 1, animation.index);
  static Uint8List encode(int id, int opcode, int argument,
      {int source = 0, int target = 0}) {
    if (id <= 0 || id > 0xffffffff) {
      throw const FormatException('Invalid request ID');
    }
    if (opcode < 1 ||
        opcode > 4 ||
        argument < 0 ||
        (opcode == 1 && (argument > 3 || source != 0)) ||
        (opcode == 2 && (argument > 1 || source != 0)) ||
        (opcode == 3 &&
            (argument > 1 ||
                source < 1 ||
                source > 2 ||
                target <= 0 ||
                target > 0xffffffff)) ||
        (opcode == 4 && (argument != 0 || source != 0))) {
      throw const FormatException('Invalid command arguments');
    }
    final b = Uint8List(opcode == 3 ? 12 : 8)
      ..[0] = version
      ..[1] = opcode
      ..[6] = argument
      ..[7] = source;
    ByteData.sublistView(b).setUint32(2, id, Endian.little);
    if (opcode == 3) {
      ByteData.sublistView(b).setUint32(8, target, Endian.little);
    }
    return b;
  }

  static (int, AnimationState) parseCommand(Uint8List b) {
    if (b.length != 8 || b[0] != 1 || b[1] != 1 || b[6] > 3 || b[7] != 0) {
      throw const FormatException('Invalid command');
    }
    final id = ByteData.sublistView(b).getUint32(2, Endian.little);
    if (id == 0) throw const FormatException('Invalid request ID');
    return (id, AnimationState.values[b[6]]);
  }

  static void validateCapabilities(Uint8List b) {
    if (b.length != 8 ||
        b[0] != 1 ||
        b[1] != 8 ||
        (b[2] & 15) != 15 ||
        (b[4] & 15) != 15 ||
        (b[5] & 3) != 3) {
      throw const FormatException('Board does not support XUNA local MVP v1');
    }
  }

  static DeviceStatus parseStatus(Uint8List b) {
    if (b.length != 16 || b[0] != 1 || b[1] > 2 || b[6] > 7 || b[7] > 3) {
      throw const FormatException('Invalid status');
    }
    final d = ByteData.sublistView(b), id = d.getUint32(2, Endian.little);
    if (b[1] != 1 && (id != 0 || b[6] != 0)) {
      throw const FormatException('Invalid unsolicited status');
    }
    return DeviceStatus(
        AnimationState.values[b[7]], d.getUint32(8, Endian.little),
        kind: b[1], requestId: id, result: b[6]);
  }

  static LifeSummary parseLife(Uint8List b) {
    if (b.length != 20 ||
        b[0] != 1 ||
        b[1] != 20 ||
        b[2] > 1 ||
        b[3] > 1 ||
        b[16] > 1 ||
        b[17] > 1 ||
        b[18] > 1 ||
        b[19] > 8) {
      throw const FormatException('Invalid life summary');
    }
    final d = ByteData.sublistView(b);
    return LifeSummary(
        context: InteractionContext.values[b[2]],
        action: AnimationState.values[b[3]],
        activeSeconds: d.getUint32(4, Endian.little),
        events: d.getUint32(8, Endian.little),
        decisionId: d.getUint32(12, Endian.little),
        quietChoice: AnimationState.values[b[16]],
        playChoice: AnimationState.values[b[17]],
        canFeedback: b[18] == 1,
        memories: b[19]);
  }

  static List<MemoryEpisode> parseMemories(Uint8List b, int page) {
    if (b.length != 20 || b[0] != 1 || b[1] > 4 || b[2] != page || b[3] != 0) {
      throw const FormatException('Invalid memory page');
    }
    return List.generate(b[1], (i) {
      final offset = 4 + i * 4;
      if (b[offset] > 1 ||
          b[offset + 1] > 1 ||
          b[offset + 2] > 1 ||
          b[offset + 3] < 1 ||
          b[offset + 3] > 2) {
        throw const FormatException('Invalid memory episode');
      }
      return MemoryEpisode(
          InteractionContext.values[b[offset]],
          AnimationState.values[b[offset + 1]],
          b[offset + 2] == 1,
          b[offset + 3] == 2);
    });
  }
}
