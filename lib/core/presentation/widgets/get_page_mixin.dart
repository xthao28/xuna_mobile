import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xuna_mobile/core/domain/entity/app_data.dart';
import 'package:xuna_mobile/core/presentation/controllers/app_controller.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/core/presentation/navigation/navigation_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/utils/utils_src.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

mixin GetPageMixin<T extends BaseGetxController> on GetView<T> {
  late final nav = sl<AppNavigator>();
  late final appData = sl<AppData>();
  late final appCtrl = sl<AppController>();

  @override
  T get controller => _controller;

  late final _controller = (isFactory ? slf<T>() : sl<T>());

  bool get isFactory => false;

  bool get isAppWidget => false;

  double get toolbarHeight => kToolbarHeight;

  /// Khi màn hình không có appBar cần override lại hàm này để trả về false
  ///
  /// `hasAppBar` dùng để xử lý cho trường hợp loading overlay
  ///
  /// Nếu có appbar thì cho phép bấm nút back ở appBar, ngược lại thì không
  bool get hasAppBar => true;

  @override
  Widget build(BuildContext context) {
    final screenPadding = MediaQuery.paddingOf(context);
    final appBarHeight = screenPadding.top + toolbarHeight;
    return isAppWidget
        ? buildPage(context)
        : Stack(
            children: [
              buildPage(context),
              Obx(
                () {
                  if (controller.isLoadingOverlay.value) {
                    return Stack(
                      children: [
                        // Container này sẽ chiếm full màn hình và chặn sự kiện tap
                        // Nhưng sẽ có xử lý thêm margin ở trên và dưới để cho phép tap vào appBar và bottom banner ad
                        GestureDetector(
                          onTap: () {
                            // Nếu đang mở bàn phím thì user có thể bấm vào cái loading này để ẩn bàn phím đi
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: Container(
                            /// Chiều cao của appBar
                            margin: EdgeInsets.only(
                              top: hasAppBar ? appBarHeight : 0,
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                        // Cái overlay này sẽ không chặn sự kiện tap, tức là chỉ hiển thị,
                        // user vẫn bấm được vào cá widget bên dưới nó bình thường, cái Container bên trên mới là cái chặn sự kiện tap
                        IgnorePointer(
                          ignoring: true,
                          child: Container(
                            color: Colors.black38,
                            child: const Center(
                              child: CupertinoActivityIndicator(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          );
  }

  Widget buildPage(BuildContext context);

  Widget baseShowLoading(WidgetCallback child, {Color? colorIcon}) {
    return Obx(
      () => controller.isLoading.value
          ? Center(child: UtilWidget.buildLoading(colorIcon: colorIcon))
          : child(),
    );
  }
}
