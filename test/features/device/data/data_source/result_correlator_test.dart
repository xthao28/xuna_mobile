import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/data_source/result_correlator.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

import '../../../../helpers/device_matchers.dart';

DeviceStatusModel _status({
  required int kind,
  int requestId = 0,
  int resultCode = DeviceProtocol.resultOk,
}) =>
    DeviceStatusModel(
      kind: kind,
      requestId: requestId,
      resultCode: resultCode,
      animationCode: DeviceProtocol.animationHappy,
      sequence: 1,
    );

void main() {
  test(
      'matches only command result ID, rejects concurrent request, clears on disconnect',
      () async {
    final correlator = ResultCorrelator();
    final future = correlator.begin(1);
    expect(
      () => correlator.begin(2),
      throwsA(isDeviceException(DeviceExceptionKind.busy)),
    );
    correlator.accept(_status(kind: DeviceProtocol.statusStateChange));
    expect(correlator.busy, true);
    correlator.accept(_status(kind: DeviceProtocol.statusResult, requestId: 2));
    expect(correlator.busy, true);
    correlator.accept(_status(kind: DeviceProtocol.statusResult, requestId: 1));
    expect((await future).animationCode, DeviceProtocol.animationHappy);
    final pending = correlator.begin(3);
    correlator.cancel(StateError('Disconnect'));
    await expectLater(pending, throwsStateError);
    expect(correlator.busy, false);
  });

  test('timeout does not allow late result to complete new ID', () async {
    final correlator = ResultCorrelator();
    await expectLater(
      correlator.begin(1, timeout: const Duration(milliseconds: 5)),
      throwsA(isDeviceException(DeviceExceptionKind.outcomeUnknown)),
    );
    final next = correlator.begin(2);
    correlator.accept(_status(kind: DeviceProtocol.statusResult, requestId: 1));
    expect(correlator.busy, true);
    correlator.accept(_status(
      kind: DeviceProtocol.statusResult,
      requestId: 2,
      resultCode: DeviceProtocol.resultInvalidArgument,
    ));
    await expectLater(
      next,
      throwsA(isDeviceException(DeviceExceptionKind.rejected)
          .having((e) => e.resultCode, 'resultCode', 4)),
    );
  });
}
