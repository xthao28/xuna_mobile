// Localization keys synchronized with assets/locales/vi_VN.json.

class AppTranslation {
  static Map<String, Map<String, String>> translations = {
    'vi_VN': Locales.vi_VN
  };
}

class LocaleKeys {
  LocaleKeys._();
  static const app_name = 'app_name';
  static const app_somethingWentWrong = 'app_somethingWentWrong';
  static const app_cannotConnectToServer = 'app_cannotConnectToServer';
  static const dialog_close = 'dialog_close';
  static const dialog_errorInternalServer = 'dialog_errorInternalServer';
  static const dialog_error502 = 'dialog_error502';
  static const dialog_error503 = 'dialog_error503';
  static const dialog_error400 = 'dialog_error400';
  static const dialog_error404 = 'dialog_error404';
  static const dialog_error401 = 'dialog_error401';
  static const dialog_error429 = 'dialog_error429';
  static const dialog_cancel = 'dialog_cancel';
  static const dialog_confirm = 'dialog_confirm';
}

class Locales {
  static const vi_VN = <String, String>{
    "app_name": "XUNA",
    "app_somethingWentWrong": "Đã có lỗi xảy ra, vui lòng thử lại sau.",
    "app_cannotConnectToServer":
        "Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối internet của bạn.",
    "dialog_close": "Đóng",
    "dialog_errorInternalServer":
        "Lỗi xử lý hệ thống\nQuý khách vui lòng thử lại sau!!!",
    "dialog_error502": "Server đang bảo trì. Quý khách vui lòng quay lại sau.",
    "dialog_error503":
        "Server đang bảo trì. Quý khách vui lòng quay lại sau một vài phút.",
    "dialog_error400": "Dữ liệu gửi đi không hợp lệ!",
    "dialog_error404":
        "Không tìm thấy đường dẫn này, xin vui lòng liên hệ Admin",
    "dialog_error401":
        "Phiên đăng nhập đã hết hạn\nQuý khách vui lòng đăng nhập lại",
    "dialog_error429":
        "Hiện tại có quá nhiều lượt truy cập. Vui lòng thử lại sau vài phút.",
    "dialog_cancel": "Hủy",
    "dialog_confirm": "Đồng ý"
  };
}
