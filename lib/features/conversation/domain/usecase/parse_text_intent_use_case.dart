import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/text_intent.dart';

/// Deliberately limited local text parser: exact phrases only. No LLM, and
/// the input text is never retained.
class ParseTextIntentUseCase extends UseCase<String, TextIntent> {
  const ParseTextIntentUseCase();

  static const _play = {'chơi', 'chơi nhé', 'play'};
  static const _quiet = {'yên tĩnh', 'nghỉ nhé', 'quiet'};
  static const _approve = {'thích', 'tôi thích', 'like'};
  static const _reject = {'không thích', 'tôi không thích', 'dislike'};

  @override
  TextIntent execute(String input) {
    final text = input.trim().toLowerCase().replaceAll(RegExp(r'[.!?]+$'), '');
    if (_play.contains(text)) return TextIntent.play;
    if (_quiet.contains(text)) return TextIntent.quiet;
    if (_approve.contains(text)) return TextIntent.approve;
    if (_reject.contains(text)) return TextIntent.reject;
    return TextIntent.unknown;
  }
}
