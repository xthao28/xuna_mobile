import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/core/presentation/widgets/get_page_mixin.dart';
import 'package:get/get.dart';

abstract class BaseGetPageFactory<T extends BaseGetxController>
    extends GetView<T> with GetPageMixin {
  BaseGetPageFactory({super.key});

  @override
  final isFactory = true;
}
