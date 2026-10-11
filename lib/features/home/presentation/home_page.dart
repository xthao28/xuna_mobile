import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_page.dart';
import 'package:xuna_mobile/features/device/domain/device_repository.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';

class HomePage extends BaseGetPage<HomeController> {
  HomePage({super.key});
  @override
  Widget buildPage(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('XUNA')),
        body: Obx(() => ListView(padding: const EdgeInsets.all(24), children: [
              const Text('SIMULATOR · FAKE BLE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange)),
              const Text('Chế độ phát triển: không kết nối board thật.'),
              const SizedBox(height: 24),
              Text(controller.message.value),
              const SizedBox(height: 24),
              Icon(
                  controller.animation.value == AnimationState.happy
                      ? Icons.sentiment_very_satisfied
                      : Icons.sentiment_satisfied,
                  size: 100),
              Center(child: Text(controller.animation.value.name)),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed:
                      controller.connected.value ? null : controller.scan,
                  child: const Text('Tìm XUNA mô phỏng')),
              for (final device in controller.devices)
                ListTile(
                    title: Text(device),
                    trailing: const Icon(Icons.bluetooth),
                    onTap: controller.connected.value
                        ? null
                        : () => controller.connect(device)),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: controller.connected.value
                            ? () => controller.setAnimation(AnimationState.idle)
                            : null,
                        child: const Text('Idle'))),
                const SizedBox(width: 12),
                Expanded(
                    child: FilledButton(
                        onPressed: controller.connected.value
                            ? () =>
                                controller.setAnimation(AnimationState.happy)
                            : null,
                        child: const Text('Happy'))),
              ]),
              const Text('Happy trở về idle sau 2,4 giây trong mô phỏng.'),
              TextButton(
                  onPressed:
                      controller.connected.value ? controller.disconnect : null,
                  child: const Text('Ngắt kết nối')),
            ])),
      );
}
