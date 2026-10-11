import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/result_correlator.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';

void main() {
  test(
      'matches only command result ID, rejects concurrent request, clears on disconnect',
      () async {
    final c = ResultCorrelator();
    final future = c.begin(1);
    expect(() => c.begin(2), throwsStateError);
    c.accept(const DeviceStatus(AnimationState.happy, 1, kind: 2));
    expect(c.busy, true);
    c.accept(
        const DeviceStatus(AnimationState.happy, 1, kind: 1, requestId: 2));
    expect(c.busy, true);
    c.accept(
        const DeviceStatus(AnimationState.happy, 1, kind: 1, requestId: 1));
    expect((await future).animation, AnimationState.happy);
    final pending = c.begin(3);
    c.cancel(StateError('Disconnect'));
    await expectLater(pending, throwsStateError);
    expect(c.busy, false);
  });
  test('timeout does not allow late result to complete new ID', () async {
    final c = ResultCorrelator();
    await expectLater(c.begin(1, timeout: const Duration(milliseconds: 5)),
        throwsA(isA<Exception>()));
    final next = c.begin(2);
    c.accept(
        const DeviceStatus(AnimationState.happy, 1, kind: 1, requestId: 1));
    expect(c.busy, true);
    c.accept(const DeviceStatus(AnimationState.idle, 1,
        kind: 1, requestId: 2, result: 4));
    await expectLater(next, throwsStateError);
  });
}
