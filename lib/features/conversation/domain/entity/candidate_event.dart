import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/day_part.dart';
import 'package:xuna_mobile/features/conversation/domain/entity/preference_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';

/// Layer A intents (plan §11.2, S22).
enum CandidateType { rateLastReaction, statePreference, requestContext, askWhy }

/// Where the evidence comes from: a rating of what XUNA did, or something
/// the owner said about what they like.
enum CandidateProvenance { userFeedback, userStated }

enum PreferencePolarity { like, dislike }

/// Something the owner may have meant, extracted locally from text. It is a
/// proposal only: teaching candidates need the owner's confirmation and the
/// device re-validates everything (mobile AGENTS §6). Typed fields replace
/// the plan's generic slot map.
class CandidateEvent extends Equatable {
  const CandidateEvent({
    required this.type,
    this.polarity,
    this.action,
    this.context,
    this.dayPart = DayPart.unknown,
    this.requestedContext,
  });

  final CandidateType type;

  /// [CandidateType.rateLastReaction] and [CandidateType.statePreference].
  final PreferencePolarity? polarity;

  /// [CandidateType.statePreference]: idle, happy or curious only (D5).
  final AnimationState? action;

  /// [CandidateType.statePreference]; null until the owner answers the
  /// follow-up question (S22-4).
  final PreferenceContext? context;

  final DayPart dayPart;

  /// [CandidateType.requestContext].
  final InteractionContext? requestedContext;

  CandidateProvenance get provenance => type == CandidateType.statePreference
      ? CandidateProvenance.userStated
      : CandidateProvenance.userFeedback;

  /// Ratings and statements teach XUNA, so the owner confirms them first.
  bool get requiresConfirmation =>
      type == CandidateType.rateLastReaction ||
      type == CandidateType.statePreference;

  /// False while a statement still lacks its context.
  bool get isComplete =>
      type != CandidateType.statePreference || context != null;

  CandidateEvent withContext(PreferenceContext value) => CandidateEvent(
        type: type,
        polarity: polarity,
        action: action,
        context: value,
        dayPart: dayPart,
        requestedContext: requestedContext,
      );

  @override
  List<Object?> get props =>
      [type, polarity, action, context, dayPart, requestedContext];
}
