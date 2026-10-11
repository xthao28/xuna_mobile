import 'package:get/get.dart';

import 'app_data.dart';

class AppDataImpl extends AppData {
  /// Số lượng thông báo chưa đọc
  final _totalUnreadNotification = 0.obs;

  @override
  set totalUnreadNotification(int value) {
    _totalUnreadNotification.value = value;
  }

  @override
  int get totalUnreadNotification => _totalUnreadNotification.value;
}
