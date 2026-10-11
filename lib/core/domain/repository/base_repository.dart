import 'package:dio/dio.dart';
import 'package:get/get_instance/src/lifecycle.dart';

abstract class BaseRepository with GetLifeCycleBase {
  BaseRepository() {
    $configureLifeCycle();
  }

  final _cancelTokens = <CancelToken>[];

  CancelToken? get cancelToken {
    if (isClosed) return null;

    final cancelToken = CancelToken();
    _cancelTokens.add(cancelToken);
    return cancelToken;
  }

  /// Cancel all requests
  ///
  /// Dùng trong trường hợp search, khi người dùng nhập liên tục, kết quả cũ chưa trả về
  ///
  /// mã đã request mới, thì cancel tất cả request cũ
  ///
  /// Việc cancel all request sẽ không ảnh hưởng tới các request khác vì project được chia theo clean architecture
  ///
  /// Mỗi use case khi gọi API sẽ có 1 repository riêng, nên cancel all request chỉ ảnh hưởng tới use case đó
  ///
  /// VD: Với search use case thì khi cancel all request chỉ cancel request của search use case mà thôi :)
  void cancelAllRequests() {
    if (isClosed) return;
    for (final cancelToken in _cancelTokens) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Cancel all requests');
      }
    }
    _cancelTokens.clear();
  }

  @override
  void onClose() {
    for (final cancelToken in _cancelTokens) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Repository disposed');
      }
    }
    _cancelTokens.clear();
    super.onClose();
  }
}
