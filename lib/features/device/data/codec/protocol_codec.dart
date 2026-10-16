import 'dart:typed_data';

import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/data/model/life_summary_model.dart';
import 'package:xuna_mobile/features/device/data/model/memory_episode_model.dart';

/// Binary codec for XUNA BLE protocol v1. Every method throws
/// [FormatException] on a malformed frame or invalid argument.
abstract final class ProtocolCodec {
  static const _commandLength = 8;
  static const _feedbackCommandLength = 12;
  static const _capabilitiesLength = 8;
  static const _statusLength = 16;
  static const _lifeLength = 20;
  static const _memoryPageLength = 20;
  static const _episodesPerPage = 4;

  static Uint8List encode(int requestId, DeviceCommandModel command) {
    _validate(requestId, command);
    final isFeedback = command.opcode == DeviceProtocol.opcodeFeedback;
    final isStated = command.opcode == DeviceProtocol.opcodeStatedPreference;
    final bytes = Uint8List(
        isFeedback || isStated ? _feedbackCommandLength : _commandLength)
      ..[0] = DeviceProtocol.version
      ..[1] = command.opcode
      ..[6] = command.argument
      ..[7] = command.source;
    final data = ByteData.sublistView(bytes)
      ..setUint32(2, requestId, Endian.little);
    if (isFeedback) data.setUint32(8, command.target, Endian.little);
    if (isStated) {
      bytes[8] = command.target & 0xff;
      bytes[9] = (command.target >> 8) & 0xff;
    }
    return bytes;
  }

  /// Decodes a command frame with the same validation as [encode].
  static (int, DeviceCommandModel) decodeCommand(Uint8List bytes) {
    if (bytes.length < _commandLength || bytes[0] != DeviceProtocol.version) {
      throw const FormatException('Invalid command');
    }
    final isFeedback = bytes[1] == DeviceProtocol.opcodeFeedback;
    final isStated = bytes[1] == DeviceProtocol.opcodeStatedPreference;
    if (bytes.length !=
        (isFeedback || isStated ? _feedbackCommandLength : _commandLength)) {
      throw const FormatException('Invalid command');
    }
    final data = ByteData.sublistView(bytes);
    final requestId = data.getUint32(2, Endian.little);
    final command = DeviceCommandModel(
      opcode: bytes[1],
      argument: bytes[6],
      source: bytes[7],
      target: isFeedback
          ? data.getUint32(8, Endian.little)
          : isStated
              ? bytes[8] | (bytes[9] << 8)
              : 0,
    );
    _validate(requestId, command);
    return (requestId, command);
  }

  /// Accepts only devices that support every local MVP v1 command,
  /// animation and flag.
  static void validateCapabilities(Uint8List bytes) {
    if (bytes.length != _capabilitiesLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] != _capabilitiesLength ||
        (bytes[2] & 0x0f) != 0x0f ||
        (bytes[4] & 0x0f) != 0x0f ||
        (bytes[5] & 0x03) != 0x03) {
      throw const FormatException('Board does not support XUNA local MVP v1');
    }
  }

  static bool supportsStatedPreference(Uint8List bytes) {
    validateCapabilities(bytes);
    return (bytes[2] & DeviceProtocol.capabilityStatedPreference) != 0;
  }

  static DeviceStatusModel decodeStatus(Uint8List bytes) {
    if (bytes.length != _statusLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] > DeviceProtocol.statusStateChange ||
        bytes[6] > DeviceProtocol.resultNotReady ||
        bytes[7] > DeviceProtocol.animationCurious) {
      throw const FormatException('Invalid status');
    }
    final data = ByteData.sublistView(bytes);
    final kind = bytes[1];
    final requestId = data.getUint32(2, Endian.little);
    if (kind != DeviceProtocol.statusResult &&
        (requestId != 0 || bytes[6] != DeviceProtocol.resultOk)) {
      throw const FormatException('Invalid unsolicited status');
    }
    return DeviceStatusModel(
      kind: kind,
      requestId: requestId,
      resultCode: bytes[6],
      animationCode: bytes[7],
      sequence: data.getUint32(8, Endian.little),
    );
  }

  static LifeSummaryModel decodeLife(Uint8List bytes) {
    if (bytes.length != _lifeLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] != _lifeLength ||
        bytes[2] > DeviceProtocol.contextPlay ||
        bytes[3] > DeviceProtocol.animationHappy ||
        bytes[16] > DeviceProtocol.animationHappy ||
        bytes[17] > DeviceProtocol.animationHappy ||
        bytes[18] > 1 ||
        bytes[19] > DeviceProtocol.maxMemoryEpisodes) {
      throw const FormatException('Invalid life summary');
    }
    final data = ByteData.sublistView(bytes);
    return LifeSummaryModel(
      contextCode: bytes[2],
      actionCode: bytes[3],
      activeSeconds: data.getUint32(4, Endian.little),
      events: data.getUint32(8, Endian.little),
      decisionId: data.getUint32(12, Endian.little),
      quietChoiceCode: bytes[16],
      playChoiceCode: bytes[17],
      canFeedback: bytes[18] == 1,
      memoryCount: bytes[19],
    );
  }

  static List<MemoryEpisodeModel> decodeMemoryPage(Uint8List bytes, int page) {
    if (bytes.length != _memoryPageLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] > _episodesPerPage ||
        bytes[2] != page ||
        bytes[3] != 0) {
      throw const FormatException('Invalid memory page');
    }
    return List.generate(bytes[1], (index) {
      final offset = 4 + index * 4;
      if (bytes[offset] > DeviceProtocol.contextPlay ||
          bytes[offset + 1] > DeviceProtocol.animationHappy ||
          bytes[offset + 2] > 1 ||
          bytes[offset + 3] < DeviceProtocol.sourceButton ||
          bytes[offset + 3] > DeviceProtocol.sourceText) {
        throw const FormatException('Invalid memory episode');
      }
      return MemoryEpisodeModel(
        contextCode: bytes[offset],
        actionCode: bytes[offset + 1],
        approved: bytes[offset + 2] == 1,
        sourceCode: bytes[offset + 3],
      );
    });
  }

  static void _validate(int requestId, DeviceCommandModel command) {
    if (requestId <= 0 || requestId > DeviceProtocol.maxRequestId) {
      throw const FormatException('Invalid request ID');
    }
    final argument = command.argument;
    final source = command.source;
    final valid = argument >= 0 &&
        switch (command.opcode) {
          DeviceProtocol.opcodeAnimation =>
            argument <= DeviceProtocol.animationCurious &&
                source == DeviceProtocol.sourceNone,
          DeviceProtocol.opcodeSuggest =>
            argument <= DeviceProtocol.contextPlay &&
                source == DeviceProtocol.sourceNone,
          DeviceProtocol.opcodeFeedback => argument <= 1 &&
              (source == DeviceProtocol.sourceButton ||
                  source == DeviceProtocol.sourceText) &&
              command.target > 0 &&
              command.target <= DeviceProtocol.maxRequestId,
          DeviceProtocol.opcodeForget =>
            argument == 0 && source == DeviceProtocol.sourceNone,
          DeviceProtocol.opcodeStatedPreference => argument <= 1 &&
              source == DeviceProtocol.sourceText &&
              bytesTargetValid(command.target),
          _ => false,
        };
    if (!valid) throw const FormatException('Invalid command arguments');
  }

  static bool bytesTargetValid(int target) =>
      (target & 0x0f) <= 4 &&
      ((target >> 4) & 0x0f) <= 2 &&
      ((target >> 8) & 0xff) <= DeviceProtocol.animationCurious;
}
