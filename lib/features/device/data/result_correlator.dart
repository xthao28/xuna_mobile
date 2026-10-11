import 'dart:async';
import '../domain/device_repository.dart';

/// One request per session. Late/stale notifications cannot complete another ID.
class ResultCorrelator {
  Completer<DeviceStatus>? _pending;
  Timer? _timer;
  int _id = 0;
  bool get busy => _pending != null;
  Future<DeviceStatus> begin(int id,
      {Duration timeout = const Duration(seconds: 3)}) {
    if (busy) throw StateError('Đang chờ XUNA phản hồi.');
    final pending = Completer<DeviceStatus>();
    _pending = pending;
    _id = id;
    _timer = Timer(
        timeout,
        () => cancel(TimeoutException(
            'Chưa xác định kết quả. Không tự gửi lại; hãy đọc lại status.')));
    unawaited(pending.future
        .then<void>((_) {}, onError: (Object _, StackTrace __) {}));
    return pending.future;
  }

  void accept(DeviceStatus status) {
    if (status.kind != 1 || status.requestId != _id || _pending == null) return;
    final pending = _pending!;
    _pending = null;
    _timer?.cancel();
    if (status.result == 0) {
      pending.complete(status);
    } else {
      pending
          .completeError(StateError('XUNA từ chối yêu cầu: ${status.result}'));
    }
  }

  void cancel(Object error) {
    final pending = _pending;
    _pending = null;
    _timer?.cancel();
    if (pending != null && !pending.isCompleted) pending.completeError(error);
  }
}
