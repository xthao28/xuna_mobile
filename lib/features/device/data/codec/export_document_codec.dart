import 'dart:convert';

import 'package:crypto/crypto.dart';

/// `xuna.export.v1` envelope: `{"format", "sha256", "payload"}`.
///
/// `sha256` is the lowercase hex SHA-256 of the UTF-8 bytes of the payload
/// serialized as compact JSON in stored key order. Python check:
/// `sha256(json.dumps(doc["payload"], separators=(",", ":"),
/// ensure_ascii=False).encode()).hexdigest()`. Payload values are strings,
/// integers, booleans, null, lists and maps only, so both encoders agree.
abstract final class ExportDocumentCodec {
  static const format = 'xuna.export.v1';

  static String hash(Map<String, Object?> payload) =>
      sha256.convert(utf8.encode(jsonEncode(payload))).toString();

  static String encode(Map<String, Object?> payload) =>
      const JsonEncoder.withIndent('  ').convert({
        'format': format,
        'sha256': hash(payload),
        'payload': payload,
      });

  /// Returns the payload; throws [FormatException] when the format is
  /// unknown or the hash does not match.
  static Map<String, Object?> decode(String document) {
    final json = jsonDecode(document);
    if (json is! Map<String, dynamic> ||
        json['format'] != format ||
        json['payload'] is! Map<String, dynamic>) {
      throw const FormatException('Not a xuna.export.v1 document');
    }
    final payload = Map<String, Object?>.from(json['payload'] as Map);
    if (json['sha256'] != hash(payload)) {
      throw const FormatException('Export hash mismatch');
    }
    return payload;
  }
}
