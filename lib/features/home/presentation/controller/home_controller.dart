import 'dart:async';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';

class HomeController extends BaseGetxController {
  HomeController(this.repository, this.requestAnimation);
  final DeviceRepository repository;
  final RequestAnimation requestAnimation;
  final devices = <String>[].obs;
  final connected = false.obs;
  final animation = AnimationState.idle.obs;
  final message = 'Chưa kết nối'.obs;
  StreamSubscription<DeviceStatus>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = repository.statuses.listen((status) {
      if (connected.value) animation.value = status.animation;
    });
  }

  Future<void> scan() async {
    devices.assignAll(await repository.scan());
    message.value = 'Tìm thấy thiết bị mô phỏng';
  }

  Future<void> connect(String id) async {
    final status = await repository.connect(id);
    animation.value = status.animation;
    connected.value = true;
    message.value = 'Đã kết nối mô phỏng';
  }

  Future<void> setAnimation(AnimationState value) async {
    if (!connected.value) return;
    final status = await requestAnimation.execute(value);
    animation.value = status.animation;
  }

  Future<void> disconnect() async {
    await repository.disconnect();
    connected.value = false;
    message.value = 'Đã ngắt kết nối';
  }

  @override
  void onClose() {
    _subscription?.cancel();
    repository.disconnect();
    super.onClose();
  }
}
