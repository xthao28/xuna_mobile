import 'package:xuna_mobile/core/presentation/bindings/base_bindings_factory.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/core/presentation/widgets/get_page_mixin.dart';
import 'package:xuna_mobile/shared/utils/utils_src.dart';
import 'package:get/get.dart';

/// Base page dùng chung cho bottom sheet và dialog
///
/// Thiết kế là các bts, dialog có thể mở nhiều lần đè lên nhau
/// và mỗi lần mở sẽ tạo một instance mới của controller.
///
/// => Dùng factory
abstract class BaseGetBtsDialog<T extends BaseGetxController> extends GetView<T>
    with GetPageMixin {
  BaseGetBtsDialog({super.key});

  @override
  T get controller => _controller;

  late final _controller = () {
    bindingFactory.dependencies();
    return Get.findFactory<T>();
  }();

  BaseBindingsFactory get bindingFactory;
}
