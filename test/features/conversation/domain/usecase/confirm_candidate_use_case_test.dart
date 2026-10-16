import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/conversation/domain/domain.src.dart';
import 'package:xuna_mobile/features/device/domain/domain.src.dart';

class _Repository extends Fake implements DeviceRepository {
  bool supported = true;
  bool timeout = false;
  int sends = 0;
  int reads = 0;
  @override
  bool get supportsStatedPreference => supported;
  @override
  Future<void> statePreference(
      {required bool likes,
      required int contextKey,
      required AnimationState action}) async {
    sends++;
    expect(contextKey, 0x13);
    if (timeout) {
      throw const DeviceException(DeviceExceptionKind.outcomeUnknown);
    }
  }

  @override
  Future<LearningExplanation?> readExplanation() async {
    reads++;
    return null;
  }
}

void main() {
  const candidate = CandidateEvent(
      type: CandidateType.statePreference,
      polarity: PreferencePolarity.like,
      context: PreferenceContext.play,
      dayPart: DayPart.evening,
      action: AnimationState.happy);
  test('unsupported firmware sends nothing', () async {
    final repository = _Repository()..supported = false;
    await expectLater(ConfirmCandidateUseCase(repository).execute(candidate),
        throwsA(isA<DeviceException>()));
    expect(repository.sends, 0);
  });
  test('ambiguous outcome reads evidence once, never resends or claims success',
      () async {
    final repository = _Repository()..timeout = true;
    await expectLater(
        ConfirmCandidateUseCase(repository).execute(candidate),
        throwsA(isA<DeviceException>().having(
            (e) => e.kind, 'kind', DeviceExceptionKind.outcomeUnknown)));
    expect(repository.sends, 1);
    expect(repository.reads, 1);
  });
}
