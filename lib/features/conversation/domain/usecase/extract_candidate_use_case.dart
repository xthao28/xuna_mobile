import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/candidate_event.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/day_part.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/extraction_result.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/preference_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';

/// Local rule extractor for Conversation Layer A (plan §11, S39), built from
/// the owner-approved S22 phrase table. Vietnamese first; English keeps the
/// V1 words only.
///
/// Closed word lists, no network and no LLM. The input is neither stored
/// nor logged. A statement becomes a candidate only when every remaining
/// word is an allowed filler, so unfamiliar prose never teaches XUNA.
/// Hypotheticals, quotes, questions about XUNA's taste and instruction-like
/// text produce [ExtractionResult.unknown].
///
/// Known limit: Vietnamese must be precomposed (NFC), which is what the
/// common Android and iOS keyboards produce.
class ExtractCandidateUseCase extends UseCase<String, ExtractionResult> {
  const ExtractCandidateUseCase();

  static const maxInputLength = 120;

  /// Resolves the single follow-up answer requested for a statement that
  /// omitted its interaction context. Unknown answers send nothing.
  PreferenceContext? resolveContext(String input) {
    final tokens = input.toLowerCase().trim().split(RegExp(r'\s+'));
    final matches =
        _takeAll(tokens, List<bool>.filled(tokens.length, false), _contexts);
    return matches.toSet().length == 1 ? matches.first : null;
  }

  static const _quoteMarks = ['"', "'", '“', '”', '‘', '’', '«', '»', '`'];
  static const _instructionMarks = [':', '{', '}', '<', '>', '=', '\\', '#'];
  static const _instructionPhrases = [
    ['bỏ', 'qua'],
    ['mọi', 'luật'],
    ['chỉ', 'thị'],
    ['ignore'],
    ['system'],
    ['prompt'],
    ['admin'],
    ['developer'],
    ['instruction'],
    ['instructions'],
  ];
  static const _hypotheticalPhrases = [
    ['giả', 'sử'],
    ['giả', 'như'],
    ['lỡ', 'như'],
    ['ví', 'dụ'],
    ['tưởng', 'tượng'],
    ['nếu'],
  ];
  static const _layerBPhrases = [
    ['gọi', 'mình', 'là'],
    ['gọi', 'tôi', 'là'],
    ['gọi', 'bạn', 'là'],
    ['tên', 'mình', 'là'],
    ['tên', 'tôi', 'là'],
    ['tên', 'bạn', 'là'],
    ['nhớ', 'gì'],
    ['nhớ', 'tên'],
    ['quên', 'tên'],
    ['quên', 'đi'],
    ['bạn', 'nhớ'],
  ];
  static const _askWhyPhrases = [
    ['tại', 'sao'],
    ['vì', 'sao'],
    ['sao', 'bạn'],
    ['sao', 'lại'],
    ['sao', 'thế'],
    ['sao', 'vậy'],
  ];
  static const _questionEndings = {'à', 'hả', 'chứ', 'nhỉ', 'chưa'};

  static const _requestPlay = {
    'chơi',
    'chơi nhé',
    'chơi đi',
    'chơi thôi',
    'chơi nha',
    'play',
  };
  static const _requestQuiet = {
    'yên tĩnh',
    'yên tĩnh nhé',
    'nghỉ nhé',
    'nghỉ đi',
    'nghỉ thôi',
    'nghỉ nha',
    'quiet',
  };

  static const _rateLike = {
    'thích',
    'rất thích',
    'thích lắm',
    'thích quá',
    'thích lắm luôn',
    'thích cái đó',
    'thích cái này',
    'thích lần này',
    'like',
  };
  static const _rateDislike = {
    'không thích',
    'chẳng thích',
    'không thích lắm',
    'không thích cái đó',
    'không thích cái này',
    'không thích lần này',
    'dislike',
  };

  // Longest phrases first so "vui vẻ" wins over "vui".
  static const _contexts = <(List<String>, PreferenceContext)>[
    (['khi', 'mình', 'bấm', 'nút'], PreferenceContext.greeting),
    (['khi', 'tôi', 'bấm', 'nút'], PreferenceContext.greeting),
    (['khi', 'bấm', 'nút'], PreferenceContext.greeting),
    (['khi', 'mình', 'chào'], PreferenceContext.greeting),
    (['lúc', 'mình', 'chào'], PreferenceContext.greeting),
    (['khi', 'tôi', 'chào'], PreferenceContext.greeting),
    (['khi', 'chào'], PreferenceContext.greeting),
    (['lúc', 'chào'], PreferenceContext.greeting),
    (['lúc', 'yên', 'tĩnh'], PreferenceContext.quiet),
    (['khi', 'yên', 'tĩnh'], PreferenceContext.quiet),
    (['khi', 'nghỉ'], PreferenceContext.quiet),
    (['lúc', 'nghỉ'], PreferenceContext.quiet),
    (['khi', 'chơi'], PreferenceContext.play),
    (['lúc', 'chơi'], PreferenceContext.play),
  ];
  static const _dayParts = <(List<String>, DayPart)>[
    (['buổi', 'sáng'], DayPart.morning),
    (['buổi', 'chiều'], DayPart.afternoon),
    (['buổi', 'tối'], DayPart.evening),
    (['buổi', 'đêm'], DayPart.night),
    (['ban', 'đêm'], DayPart.night),
  ];
  static const _actions = <(List<String>, AnimationState)>[
    (['ngó', 'nghiêng'], AnimationState.curious),
    (['ngồi', 'yên'], AnimationState.idle),
    (['yên', 'lặng'], AnimationState.idle),
    (['vui', 'vẻ'], AnimationState.happy),
    (['tò', 'mò'], AnimationState.curious),
    (['nhảy'], AnimationState.happy),
    (['nghỉ'], AnimationState.idle),
    (['vui'], AnimationState.happy),
  ];

  /// Words a statement may contain besides its slots and polarity.
  static const _fillers = {
    'mình',
    'tôi',
    'bạn',
    'xuna',
    'thích',
    'không',
    'chẳng',
    'đừng',
    'khi',
    'lúc',
    'vào',
    'lắm',
    'rất',
    'nhất',
    'nhé',
    'nha',
    'mà',
    'hơn',
    'là',
    'và',
    'hay',
    'được',
    'cái',
    'đó',
    'này',
    'thì',
    'nữa',
    'cũng',
    'luôn',
  };

  @override
  ExtractionResult execute(String input) {
    if (input.length > maxInputLength) return ExtractionResult.unknown;
    final lower = input.toLowerCase();
    if (_quoteMarks.any(lower.contains) ||
        _instructionMarks.any(lower.contains)) {
      return ExtractionResult.unknown;
    }
    final isQuestion = lower.contains('?');
    final tokens = lower
        .replaceAll(RegExp(r'[?.,;!…~]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return ExtractionResult.unknown;
    final text = tokens.join(' ');

    if (_containsAny(tokens, _instructionPhrases) ||
        _containsAny(tokens, _hypotheticalPhrases)) {
      return ExtractionResult.unknown;
    }
    if (_containsAny(tokens, _layerBPhrases)) {
      return const ExtractionResult(ExtractionOutcome.notAvailableYet);
    }
    if (_containsAny(tokens, _askWhyPhrases)) {
      return const ExtractionResult(
        ExtractionOutcome.candidate,
        candidate: CandidateEvent(type: CandidateType.askWhy),
      );
    }
    if (isQuestion || _looksLikeQuestion(tokens)) {
      return ExtractionResult.unknown;
    }

    final request = _requestedContext(text);
    if (request != null) {
      return ExtractionResult(
        ExtractionOutcome.candidate,
        candidate: CandidateEvent(
          type: CandidateType.requestContext,
          requestedContext: request,
        ),
      );
    }

    final rating = _rating(tokens);
    if (rating != null) {
      return ExtractionResult(
        ExtractionOutcome.candidate,
        candidate: CandidateEvent(
          type: CandidateType.rateLastReaction,
          polarity: rating,
        ),
      );
    }
    return _statement(tokens);
  }

  ExtractionResult _statement(List<String> tokens) {
    final polarity = _polarity(tokens);
    if (polarity == null) return ExtractionResult.unknown;

    final consumed = List<bool>.filled(tokens.length, false);
    final contexts = _takeAll(tokens, consumed, _contexts);
    final dayParts = _takeAll(tokens, consumed, _dayParts);
    final actions = _takeAll(tokens, consumed, _actions);
    final leftover = [
      for (var i = 0; i < tokens.length; i++)
        if (!consumed[i]) tokens[i],
    ];
    final strangers = leftover.where((word) => !_fillers.contains(word));

    if (actions.isEmpty) {
      // "mình thích khi bạn hát": a request for something XUNA cannot do.
      return strangers.isNotEmpty && leftover.contains('bạn')
          ? const ExtractionResult(ExtractionOutcome.unsupportedAction)
          : ExtractionResult.unknown;
    }
    if (strangers.isNotEmpty) return ExtractionResult.unknown;
    if (actions.toSet().length > 1 ||
        contexts.toSet().length > 1 ||
        dayParts.toSet().length > 1) {
      return const ExtractionResult(ExtractionOutcome.oneAtATime);
    }

    final candidate = CandidateEvent(
      type: CandidateType.statePreference,
      polarity: polarity,
      action: actions.first,
      context: contexts.isEmpty ? null : contexts.first,
      dayPart: dayParts.isEmpty ? DayPart.unknown : dayParts.first,
    );
    return ExtractionResult(
      contexts.isEmpty
          ? ExtractionOutcome.needsContext
          : ExtractionOutcome.candidate,
      candidate: candidate,
    );
  }

  /// "không"/"chẳng" only count as part of "không thích"/"chẳng thích";
  /// any other negation ("bạn không tò mò") is too ambiguous to learn from.
  PreferencePolarity? _polarity(List<String> tokens) {
    for (var i = 0; i < tokens.length; i++) {
      final negation = tokens[i] == 'không' || tokens[i] == 'chẳng';
      if (negation && (i + 1 >= tokens.length || tokens[i + 1] != 'thích')) {
        return null;
      }
    }
    if (tokens.contains('đừng') ||
        _containsPhrase(tokens, const ['không', 'thích']) ||
        _containsPhrase(tokens, const ['chẳng', 'thích'])) {
      return PreferencePolarity.dislike;
    }
    return tokens.contains('thích') ? PreferencePolarity.like : null;
  }

  PreferencePolarity? _rating(List<String> tokens) {
    final withoutSubject = tokens.first == 'tôi' || tokens.first == 'mình'
        ? tokens.skip(1)
        : tokens;
    final core = withoutSubject.join(' ');
    if (_rateLike.contains(core)) return PreferencePolarity.like;
    if (_rateDislike.contains(core)) return PreferencePolarity.dislike;
    return null;
  }

  InteractionContext? _requestedContext(String text) {
    if (_requestPlay.contains(text)) return InteractionContext.play;
    if (_requestQuiet.contains(text)) return InteractionContext.quiet;
    return null;
  }

  /// "bạn có thích tò mò không" without a question mark.
  bool _looksLikeQuestion(List<String> tokens) =>
      _questionEndings.contains(tokens.last) ||
      (tokens.last == 'không' && tokens.contains('có'));

  static List<T> _takeAll<T>(
    List<String> tokens,
    List<bool> consumed,
    List<(List<String>, T)> phrases,
  ) {
    final found = <T>[];
    for (final (phrase, value) in phrases) {
      for (var start = 0; start + phrase.length <= tokens.length; start++) {
        if (!_matchesAt(tokens, start, phrase, consumed)) continue;
        for (var i = 0; i < phrase.length; i++) {
          consumed[start + i] = true;
        }
        found.add(value);
      }
    }
    return found;
  }

  static bool _matchesAt(
    List<String> tokens,
    int start,
    List<String> phrase, [
    List<bool>? consumed,
  ]) {
    for (var i = 0; i < phrase.length; i++) {
      if (tokens[start + i] != phrase[i]) return false;
      if (consumed != null && consumed[start + i]) return false;
    }
    return true;
  }

  static bool _containsPhrase(List<String> tokens, List<String> phrase) {
    for (var start = 0; start + phrase.length <= tokens.length; start++) {
      if (_matchesAt(tokens, start, phrase)) return true;
    }
    return false;
  }

  static bool _containsAny(List<String> tokens, List<List<String>> phrases) =>
      phrases.any((phrase) => _containsPhrase(tokens, phrase));
}
