import 'dart:typed_data';

/// ExplanationCodec V1, including validation of enums, flags and Q8.8 masses.
class LearningExplanationModel {
  LearningExplanationModel._(this.bytes);
  final Uint8List bytes;
  factory LearningExplanationModel.decode(Uint8List bytes) {
    if (bytes.length != 20 ||
        bytes[0] != 1 ||
        bytes[1] != 20 ||
        bytes[2] > 2 ||
        bytes[3] > 4 ||
        bytes[4] > 2 ||
        bytes[5] > 4 ||
        bytes[6] > 1) {
      throw const FormatException('Invalid learning explanation');
    }
    final model = LearningExplanationModel._(Uint8List.fromList(bytes));
    if (model.number(8) > 1 ||
        model.number(16) > model.number(12) ||
        model.number(18) > model.number(14)) {
      throw const FormatException('Invalid explanation evidence');
    }
    return model;
  }
  double number(int offset) => (bytes[offset] | (bytes[offset + 1] << 8)) / 256;
}
