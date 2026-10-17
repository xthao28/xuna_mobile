import 'package:equatable/equatable.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';

/// One step of a streamed cloud reply. The text is display-only provider
/// output: it never becomes memory, preference or learning (AGENTS §6.4).
sealed class CloudReplyEvent extends Equatable {
  const CloudReplyEvent();
}

/// Next piece of reply text.
class CloudReplyDelta extends CloudReplyEvent {
  const CloudReplyDelta(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

/// Terminal: the reply could not be produced; the app answers locally.
class CloudReplyUnavailable extends CloudReplyEvent {
  const CloudReplyUnavailable(this.reason);

  final AccountExceptionKind reason;

  @override
  List<Object?> get props => [reason];
}
