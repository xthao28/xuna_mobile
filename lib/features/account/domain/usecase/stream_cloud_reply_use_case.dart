import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/account/domain/entity/cloud_reply_event.dart';
import 'package:xuna_mobile/features/account/domain/exception/account_exception.dart';
import 'package:xuna_mobile/features/account/domain/repository/cloud_repository.dart';

typedef StreamCloudReplyInput = ({String petId, String text});

/// One AI conversation turn (requires U3 on the server). Any failure ends the
/// stream with [CloudReplyUnavailable] so the app answers with its local
/// templates instead (offline-first). The reply is display text only and
/// is never parsed into a candidate or stored.
class StreamCloudReplyUseCase
    extends UseCase<StreamCloudReplyInput, Stream<CloudReplyEvent>> {
  const StreamCloudReplyUseCase(this._repository);

  /// Backend limit for one turn.
  static const maxChars = 500;

  final CloudRepository _repository;

  @override
  Stream<CloudReplyEvent> execute(StreamCloudReplyInput input) async* {
    final text = input.text.trim();
    if (text.isEmpty || text.length > maxChars) {
      yield const CloudReplyUnavailable(AccountExceptionKind.invalidInput);
      return;
    }
    try {
      await for (final delta
          in _repository.streamReply(petId: input.petId, text: text)) {
        if (delta.isNotEmpty) yield CloudReplyDelta(delta);
      }
    } on AccountException catch (error) {
      yield CloudReplyUnavailable(error.kind);
    }
  }
}
