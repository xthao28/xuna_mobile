import 'package:get/get.dart';

const _tagPrefix = 'SDS_';

extension GetInterfaceExt on GetInterface {
  static int _tag = 0;

  // Khi sử dụng factory, mỗi màn hình sẽ có một tag riêng biệt
  String get tag => '$_tagPrefix$_tag';

  /// Same as `Get.lazyPut` but create new instance with a static tag.
  void lazyPutFactory<S>(
    InstanceBuilderCallback<S> builder, {
    bool fenix = false,
  }) {
    lazyPut<S>(
      builder,
      tag: tag,
      fenix: fenix,
    );
  }

  /// Same as `Get.put` but create new instance with a static tag.
  S putFactory<S>(
    S dependency, {
    bool permanent = false,
    InstanceBuilderCallback<S>? builder,
  }) =>
      put<S>(
        dependency,
        tag: tag,
        permanent: permanent,
      );

  /// Same as `Get.find` but returns the instance with a static tag.
  S findFactory<S>() => find<S>(
        tag: tag,
      );

  /// The findOrNull method will return the instance if it is registered;
  /// otherwise, it will return null.
  S? findOrNull<S>({String? tag}) {
    if (isRegistered<S>(tag: tag)) {
      return find<S>(tag: tag);
    }
    return null;
  }

  T? safeArguments<T>() {
    final arguments = Get.arguments;
    return arguments is T? ? arguments : null;
  }

  static void increaseTag() {
    ++_tag;
  }
}
