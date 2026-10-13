import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/data_source/simulator_device_ble_data_source.dart';
import 'package:xuna_mobile/features/device/data/repository/device_repository_impl.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/interaction_context.dart';
import 'package:xuna_mobile/features/device/domain/entity/life_summary.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';
import 'package:xuna_mobile/features/device/domain/repository/device_repository.dart';
import 'package:xuna_mobile/features/device/domain/usecase/forget_memories_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/read_life_summary_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/send_feedback_use_case.dart';
import 'package:xuna_mobile/features/device/domain/usecase/suggest_action_use_case.dart';

import '../../../../helpers/device_matchers.dart';

class _RecordingRepository extends Fake implements DeviceRepository {
  _RecordingRepository(this.life);

  final LifeSummary life;
  final sent = <({bool approved, bool fromText, int decisionId})>[];

  @override
  Future<LifeSummary> readLife() async => life;

  @override
  Future<void> sendFeedback({
    required bool approved,
    required bool fromText,
    required int decisionId,
  }) async =>
      sent.add(
          (approved: approved, fromText: fromText, decisionId: decisionId));
}

void main() {
  test('rates the pending suggestion and refuses when none is pending',
      () async {
    final pending = _RecordingRepository(
        const LifeSummary(canFeedback: true, decisionId: 42));
    await SendFeedbackUseCase(pending)
        .execute((approved: true, fromText: true));
    expect(pending.sent, [(approved: true, fromText: true, decisionId: 42)]);

    final none = _RecordingRepository(const LifeSummary());
    await expectLater(
      SendFeedbackUseCase(none).execute((approved: true, fromText: false)),
      throwsA(isDeviceException(DeviceExceptionKind.noPendingSuggestion)),
    );
    expect(none.sent, isEmpty);
  });

  test(
      'feedback changes future policy only in its context; no duplicate feedback',
      () async {
    final repository = DeviceRepositoryImpl(SimulatorDeviceBleDataSource());
    addTearDown(repository.onClose);
    final suggest = SuggestActionUseCase(repository);
    final sendFeedback = SendFeedbackUseCase(repository);
    final readLife = ReadLifeSummaryUseCase(repository);
    await repository.connect(SimulatorDeviceBleDataSource.deviceId);

    expect(
      (await suggest.execute(InteractionContext.quiet)).animation,
      AnimationState.idle,
    );
    await sendFeedback.execute((approved: false, fromText: false));
    await expectLater(
      sendFeedback.execute((approved: false, fromText: false)),
      throwsA(isDeviceException(DeviceExceptionKind.noPendingSuggestion)),
    );
    expect(
      (await suggest.execute(InteractionContext.quiet)).animation,
      AnimationState.happy,
    );
    expect(
      (await suggest.execute(InteractionContext.play)).animation,
      AnimationState.idle,
    );
    expect((await readLife.execute()).events, 1);

    await ForgetMemoriesUseCase(repository).execute();
    expect((await readLife.execute()).events, 0);
    expect(
      (await suggest.execute(InteractionContext.quiet)).animation,
      AnimationState.idle,
    );
  });
}
