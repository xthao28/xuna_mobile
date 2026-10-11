import 'dart:async';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/controllers/base_getx_controller.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';
import 'package:xuna_mobile/features/conversation/domain/text_intent.dart';

class HomeController extends BaseGetxController {
  HomeController(this.repository, this.requestAnimation);
  final DeviceRepository repository;
  final RequestAnimation requestAnimation;
  final devices = <String>[].obs;
  final connected = false.obs, busy = false.obs;
  final animation = AnimationState.idle.obs;
  final memories = <MemoryEpisode>[].obs;
  final life = const LifeSummary().obs;
  final message = 'Chưa kết nối'.obs;
  final reply = 'Text local V1: chơi, yên tĩnh, thích, không thích.'.obs;
  final candidate = Rxn<bool>();
  StreamSubscription<DeviceStatus>? _subscription;
  Future<void> _perform(Future<void> Function() action) async {
    if (busy.value) return;
    busy.value = true;
    try {
      await action();
    } catch (e) {
      message.value = e.toString();
    } finally {
      busy.value = false;
    }
  }

  Future<void> _refresh() async {
    life.value = await repository.readLife();
    memories.assignAll(await repository.readMemories());
  }

  @override
  void onInit() {
    super.onInit();
    _subscription = repository.statuses.listen((s) {
      if (connected.value) animation.value = s.animation;
    }, onError: (Object e) {
      connected.value = false;
      candidate.value = null;
      message.value = e.toString();
    });
  }

  Future<void> scan() => _perform(() async {
        devices.assignAll(await repository.scan());
        message.value = devices.isEmpty
            ? 'Không tìm thấy XUNA.'
            : 'Tìm thấy ${devices.length} thiết bị';
      });
  Future<void> connect(String id) => _perform(() async {
        final s = await repository.connect(id);
        animation.value = s.animation;
        connected.value = true;
        candidate.value = null;
        await _refresh();
        message.value =
            repository.simulated ? 'Đã kết nối mô phỏng' : 'Đã kết nối XUNA';
      });
  Future<void> setAnimation(AnimationState value) => _perform(() async {
        if (!connected.value) return;
        candidate.value = null;
        animation.value = (await requestAnimation.execute(value)).animation;
        await _refresh();
      });
  Future<void> suggest(InteractionContext context) => _perform(() async {
        candidate.value = null;
        animation.value = (await repository.suggest(context)).animation;
        await _refresh();
        reply.value =
            'XUNA chọn ${life.value.action.name} cho ${context == InteractionContext.play ? 'chơi' : 'yên tĩnh'}. Bạn thích lựa chọn này chứ?';
      });
  Future<void> feedback(bool approved, {bool fromText = false}) =>
      _perform(() async {
        await repository.feedback(approved, fromText: fromText);
        candidate.value = null;
        await _refresh();
        reply.value =
            'Đã ghi feedback ${approved ? 'thích' : 'không thích'} cho lựa chọn trước. Lần tới XUNA dùng preference đã cập nhật.';
      });
  Future<void> forget() => _perform(() async {
        await repository.forget();
        candidate.value = null;
        await _refresh();
        reply.value = 'Đã xóa preference và memory.';
      });
  Future<void> submitText(String input) async {
    if (!connected.value) {
      reply.value = 'Kết nối XUNA trước.';
      return;
    }
    switch (parseTextIntent(input)) {
      case TextIntent.play:
        await suggest(InteractionContext.play);
      case TextIntent.quiet:
        await suggest(InteractionContext.quiet);
      case TextIntent.approve:
      case TextIntent.reject:
        if (!life.value.canFeedback) {
          reply.value = 'Hãy để XUNA chọn trước để feedback có nguồn rõ ràng.';
          return;
        }
        candidate.value = parseTextIntent(input) == TextIntent.approve;
        reply.value =
            'Xác nhận ghi feedback ${candidate.value! ? 'thích' : 'không thích'} cho lựa chọn ${life.value.action.name}?';
      case TextIntent.unknown:
        reply.value =
            'Tôi chỉ hiểu: chơi, yên tĩnh, thích, không thích. Chưa có LLM; câu này không được lưu.';
    }
  }

  Future<void> disconnect() => _perform(() async {
        await repository.disconnect();
        connected.value = false;
        candidate.value = null;
        message.value = 'Đã ngắt kết nối';
      });
  @override
  void onClose() {
    _subscription?.cancel();
    unawaited(repository.disconnect());
    super.onClose();
  }
}
