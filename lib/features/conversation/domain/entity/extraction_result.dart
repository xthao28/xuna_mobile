import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/candidate_event.dart';

/// What the local rules made of one input (S22 phrase table).
enum ExtractionOutcome {
  /// A complete candidate.
  candidate,

  /// A statement without a context: ask the follow-up question (S22-4).
  needsContext,

  /// Two actions, contexts or day parts at once: ask for one at a time.
  oneAtATime,

  /// Names something XUNA cannot do yet ("bạn hát").
  unsupportedAction,

  /// Layer B (memory, names): recognized, nothing stored.
  notAvailableYet,

  /// Anything else, including hypotheticals, quotes and injection attempts.
  unknown,
}

class ExtractionResult extends Equatable {
  const ExtractionResult(this.outcome, {this.candidate});

  static const unknown = ExtractionResult(ExtractionOutcome.unknown);

  final ExtractionOutcome outcome;

  /// Set for [ExtractionOutcome.candidate] and, without a context, for
  /// [ExtractionOutcome.needsContext].
  final CandidateEvent? candidate;

  @override
  List<Object?> get props => [outcome, candidate];
}
