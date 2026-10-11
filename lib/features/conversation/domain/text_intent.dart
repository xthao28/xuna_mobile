enum TextIntent { quiet, play, approve, reject, unknown }

/// Deliberately limited local text parser. No LLM or free-text retention.
TextIntent parseTextIntent(String input) {
  final text = input.trim().toLowerCase().replaceAll(RegExp(r'[.!?]+$'), '');
  if (['chơi', 'chơi nhé', 'play'].contains(text)) return TextIntent.play;
  if (['yên tĩnh', 'nghỉ nhé', 'quiet'].contains(text)) return TextIntent.quiet;
  if (['thích', 'tôi thích', 'like'].contains(text)) return TextIntent.approve;
  if (['không thích', 'tôi không thích', 'dislike'].contains(text)) {
    return TextIntent.reject;
  }
  return TextIntent.unknown;
}
