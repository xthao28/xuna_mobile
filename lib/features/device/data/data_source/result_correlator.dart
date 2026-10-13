import 'dart:async';

import 'package:xuna_mobile/features/device/data/codec/device_protocol.dart';
import 'package:xuna_mobile/features/device/data/model/device_status_model.dart';
import 'package:xuna_mobile/features/device/domain/exception/device_exception.dart';

/// One request in flight per session. Late or stale notifications cannot
/// complete another request ID.
class ResultCorrelator {
  Completer<DeviceStatusModel>? _pending;
  Timer? _timer;
  int _requestId = 0;

  bool get busy => _pending != null;

  /// Throws [DeviceExceptionKind.busy] while a request is pending. The
  /// returned future fails with [DeviceExceptionKind.outcomeUnknown] after
  /// [timeout], or with [DeviceExceptionKind.rejected] for a non-zero result.
  Future<DeviceStatusModel> begin(
    int requestId, {
    Duration timeout = const Duration(seconds: 3),
  }) {
    if (busy) throw const DeviceException(DeviceExceptionKind.busy);
    final pending = Completer<DeviceStatusModel>();
    _pending = pending;
    _requestId = requestId;
    _timer = Timer(
      timeout,
      () => cancel(const DeviceException(DeviceExceptionKind.outcomeUnknown)),
    );
    unawaited(pending.future
        .then<void>((_) {}, onError: (Object _, StackTrace __) {}));
    return pending.future;
  }

  void accept(DeviceStatusModel status) {
    final pending = _pending;
    if (pending == null ||
        status.kind != DeviceProtocol.statusResult ||
        status.requestId != _requestId) {
      return;
    }
    _pending = null;
    _timer?.cancel();
    if (status.resultCode == DeviceProtocol.resultOk) {
      pending.complete(status);
    } else {
      pending.completeError(DeviceException(
        DeviceExceptionKind.rejected,
        resultCode: status.resultCode,
      ));
    }
  }

  void cancel(Object error) {
    final pending = _pending;
    _pending = null;
    _timer?.cancel();
    if (pending != null && !pending.isCompleted) pending.completeError(error);
  }
}
