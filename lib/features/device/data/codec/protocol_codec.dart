import 'dart:typed_data';

import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/model/device_command_model.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/data/model/life_summary_model.dart';
import 'package:xuna_mobile/features/device/data/model/lifecycle_model.dart';
import 'package:xuna_mobile/features/device/data/model/memory_episode_model.dart';
import 'package:xuna_mobile/features/device/data/model/pet_identity_model.dart';

/// Binary codec for XUNA BLE protocol v1. Every method throws
/// [FormatException] on a malformed frame or invalid argument.
abstract final class ProtocolCodec {
  static const _commandLength = 8;
  static const _feedbackCommandLength = 12;
  static const _timeSyncCommandLength = 16;
  static const _capabilitiesLength = 8;
  static const _statusLength = 16;
  static const _lifeLength = 20;
  static const _memoryPageLength = 20;
  static const _lifecycleLength = 8;
  static const _identityLength = 24;
  static const _episodesPerPage = 4;

  static Uint8List encode(int requestId, DeviceCommandModel command) {
    _validate(requestId, command);
    final isFeedback = command.opcode == DeviceProtocol.opcodeFeedback;
    final isStated = command.opcode == DeviceProtocol.opcodeStatedPreference;
    final isTimeSync = command.opcode == DeviceProtocol.opcodeTimeSync;
    final bytes = Uint8List(isTimeSync
        ? _timeSyncCommandLength
        : isFeedback || isStated
            ? _feedbackCommandLength
            : _commandLength)
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
    if (isTimeSync) {
      data
        ..setUint32(8, command.utcSeconds, Endian.little)
        ..setInt16(12, command.timezoneOffsetMinutes, Endian.little);
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
    final isTimeSync = bytes[1] == DeviceProtocol.opcodeTimeSync;
    if (bytes.length !=
        (isTimeSync
            ? _timeSyncCommandLength
            : isFeedback || isStated
                ? _feedbackCommandLength
                : _commandLength)) {
      throw const FormatException('Invalid command');
    }
    final data = ByteData.sublistView(bytes);
    if (isTimeSync && (bytes[7] != 0 || bytes[14] != 0 || bytes[15] != 0)) {
      throw const FormatException('Invalid command');
    }
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
      utcSeconds: isTimeSync ? data.getUint32(8, Endian.little) : 0,
      timezoneOffsetMinutes: isTimeSync ? data.getInt16(12, Endian.little) : 0,
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

  static bool supportsTimeSync(Uint8List bytes) {
    validateCapabilities(bytes);
    return (bytes[2] & DeviceProtocol.capabilityTimeSync) != 0;
  }

  static bool supportsHatch(Uint8List bytes) {
    validateCapabilities(bytes);
    return (bytes[2] & DeviceProtocol.capabilityHatch) != 0;
  }

  static bool supportsIdentity(Uint8List bytes) {
    validateCapabilities(bytes);
    return (bytes[2] & DeviceProtocol.capabilityIdentity) != 0;
  }

  /// Identity V1: version, size, petId[16], origin, reserved, generation
  /// u32 LE. A device without a ready identity sends only version and size.
  static PetIdentityModel decodeIdentity(Uint8List bytes) {
    if (bytes.length != _identityLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] != _identityLength ||
        bytes[18] > 3 ||
        bytes[19] != 0) {
      throw const FormatException('Invalid identity');
    }
    final model = PetIdentityModel(
      petId: Uint8List.fromList(bytes.sublist(2, 18)),
      originCode: bytes[18],
      snapshotGeneration:
          ByteData.sublistView(bytes).getUint32(20, Endian.little),
    );
    if (!model.ready) {
      if (bytes.skip(2).any((b) => b != 0)) {
        throw const FormatException('Identity data without origin');
      }
      return model;
    }
    if ((bytes[8] & 0xf0) != 0x40 || (bytes[10] & 0xc0) != 0x80) {
      throw const FormatException('PetId is not a UUIDv4');
    }
    return model;
  }

  static LifecycleModel decodeLifecycle(Uint8List bytes) {
    if (bytes.length != _lifecycleLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] != _lifecycleLength ||
        bytes[2] > 2 ||
        bytes[3] > 1 ||
        bytes[4] > 2 ||
        (bytes[5] != 0 && bytes[5] != 2) ||
        bytes[6] > 3 ||
        (bytes[7] & 0xfe) != 0 ||
        ((bytes[7] & 1) != 0) != (bytes[5] == 2)) {
      throw const FormatException('Invalid lifecycle');
    }
    return LifecycleModel(
      identityState: bytes[2],
      growthStage: bytes[3],
      clockQuality: bytes[4],
      bornAtQuality: bytes[5],
      origin: bytes[6],
      hasBornAt: (bytes[7] & 1) != 0,
    );
  }

  static DeviceStatusModel decodeStatus(Uint8List bytes) {
    if (bytes.length != _statusLength ||
        bytes[0] != DeviceProtocol.version ||
        bytes[1] > DeviceProtocol.statusStateChange ||
        bytes[6] > DeviceProtocol.resultExpired ||
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
          DeviceProtocol.opcodeTimeSync =>
            argument == DeviceProtocol.sourcePhone &&
                source == DeviceProtocol.sourceNone &&
                command.utcSeconds > 0 &&
                command.utcSeconds <= DeviceProtocol.maxRequestId &&
                command.timezoneOffsetMinutes >= -840 &&
                command.timezoneOffsetMinutes <= 840,
          DeviceProtocol.opcodeStatedPreference => argument <= 1 &&
              source == DeviceProtocol.sourceText &&
              bytesTargetValid(command.target),
          DeviceProtocol.opcodeHatch =>
            argument == 0 && source == DeviceProtocol.sourceNone,
          _ => false,
        };
    if (!valid) throw const FormatException('Invalid command arguments');
  }

  static bool bytesTargetValid(int target) =>
      (target & 0x0f) <= 4 &&
      ((target >> 4) & 0x0f) <= 2 &&
      ((target >> 8) & 0xff) <= DeviceProtocol.animationCurious;
}
