import 'package:xuna_mobile/core/domain/usecase/base_use_case.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';

/// [fromText] marks feedback that came from a confirmed text intent.
typedef SendFeedbackInput = ({bool approved, bool fromText});

/// Rates the device's latest suggestion.
///
/// Feedback must refer to a pending suggestion, so its source is clear. This
/// is a UX pre-check; the device validates the reference again.
class SendFeedbackUseCase extends UseCase<SendFeedbackInput, void> {
  const SendFeedbackUseCase(this._repository);

  final DeviceRepository _repository;

  @override
  Future<void> execute(SendFeedbackInput input) async {
    final life = await _repository.readLife();
    if (!life.canFeedback) {
      throw const DeviceException(DeviceExceptionKind.noPendingSuggestion);
    }
    await _repository.sendFeedback(
      approved: input.approved,
      fromText: input.fromText,
      decisionId: life.decisionId,
    );
  }
}
