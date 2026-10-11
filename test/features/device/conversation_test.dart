import 'package:flutter_test/flutter_test.dart';
import 'package:xuna_mobile/features/device/data/simulator_device_repository.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';

void main() {
  test(
      'text feedback requires confirmation, stores provenance, unknown text never learns',
      () async {
    final repo = SimulatorDeviceRepository();
    final controller = HomeController(repo, RequestAnimation(repo));
    addTearDown(() {
      controller.onClose();
      repo.onClose();
    });
    await controller.connect('XUNA simulator');
    await controller.submitText('yên tĩnh');
    await controller.submitText('không thích');
    expect(controller.candidate.value, false);
    expect((await repo.readLife()).events, 0);
    await controller.feedback(false, fromText: true);
    expect((await repo.readLife()).events, 1);
    expect((await repo.readMemories()).single.fromText, true);
    await controller.submitText('Tôi thích rừng');
    expect((await repo.readLife()).events, 1);
    await controller.submitText('yên tĩnh');
    expect(controller.animation.value, AnimationState.happy);
    await controller.forget();
    expect((await repo.readMemories()), isEmpty);
  });
}
