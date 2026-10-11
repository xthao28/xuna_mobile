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
              if (controller.repository.simulated) ...[
                const Text('SIMULATOR · FAKE BLE',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange)),
                const Text(
                    'Không kết nối board thật. Memory mô phỏng chỉ tồn tại trong phiên app.'),
              ],
              const SizedBox(height: 16),
              Text(controller.message.value),
              if (controller.busy.value) const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Icon(
                  switch (controller.animation.value) {
                    AnimationState.happy => Icons.sentiment_very_satisfied,
                    AnimationState.sleep => Icons.bedtime,
                    AnimationState.curious => Icons.search,
                    _ => Icons.sentiment_satisfied
                  },
                  size: 80),
              Center(child: Text(controller.animation.value.name)),
              FilledButton(
                  onPressed: controller.connected.value || controller.busy.value
                      ? null
                      : controller.scan,
                  child: Text(controller.repository.simulated
                      ? 'Tìm XUNA mô phỏng'
                      : 'Tìm XUNA')),
              for (final device in controller.devices)
                ListTile(
                    title: Text(device),
                    trailing: const Icon(Icons.bluetooth),
                    onTap: controller.connected.value || controller.busy.value
                        ? null
                        : () => controller.connect(device)),
              Wrap(spacing: 8, children: [
                for (final state in AnimationState.values)
                  OutlinedButton(
                      onPressed:
                          controller.connected.value && !controller.busy.value
                              ? () => controller.setAnimation(state)
                              : null,
                      child: Text(
                          '${state.name[0].toUpperCase()}${state.name.substring(1)}'))
              ]),
              const Text('Happy / curious trở về idle sau 2,4 giây.'),
              TextButton(
                  onPressed:
                      controller.connected.value && !controller.busy.value
                          ? controller.disconnect
                          : null,
                  child: const Text('Ngắt kết nối')),
              const Divider(),
              const Text('Để XUNA chọn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text(
                  'Preference được học từ feedback cho từng ngữ cảnh. Các nút animation là yêu cầu trực tiếp.'),
              Wrap(spacing: 8, children: [
                for (final c in InteractionContext.values)
                  FilledButton(
                      onPressed:
                          controller.connected.value && !controller.busy.value
                              ? () => controller.suggest(c)
                              : null,
                      child: Text(
                          c == InteractionContext.play ? 'Chơi' : 'Yên tĩnh'))
              ]),
              Wrap(spacing: 8, children: [
                for (final approved in [true, false])
                  OutlinedButton(
                      onPressed: controller.connected.value &&
                              controller.life.value.canFeedback &&
                              !controller.busy.value
                          ? () => controller.feedback(approved)
                          : null,
                      child: Text(approved ? 'Thích' : 'Không thích'))
              ]),
              Text(
                  'Preference: yên tĩnh → ${controller.life.value.quietChoice.name}; chơi → ${controller.life.value.playChoice.name}'),
              Text(
                  'Feedback: ${controller.life.value.events} · Memory: ${controller.life.value.memories}/8 · Hoạt động đã ghi: ${controller.life.value.activeSeconds}s'),
              for (final e in controller.memories.reversed)
                Text(
                    '${e.context == InteractionContext.play ? "Chơi" : "Yên tĩnh"}: ${e.action.name} → ${e.approved ? "thích" : "không thích"} (${e.fromText ? "text đã xác nhận" : "nút feedback"})'),
              const Divider(),
              const Text('Conversation text V1',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text(
                  'Text local theo mẫu câu. Không dùng LLM, không lưu nội dung nhập.'),
              TextField(
                  enabled: controller.connected.value && !controller.busy.value,
                  decoration: const InputDecoration(
                      hintText: 'chơi / yên tĩnh / thích / không thích'),
                  textInputAction: TextInputAction.send,
                  onSubmitted: controller.submitText),
              const SizedBox(height: 8),
              Text(controller.reply.value),
              if (controller.candidate.value != null)
                Wrap(spacing: 8, children: [
                  FilledButton(
                      onPressed: controller.busy.value
                          ? null
                          : () => controller.feedback(
                              controller.candidate.value!,
                              fromText: true),
                      child: const Text('Xác nhận ghi feedback')),
                  TextButton(
                      onPressed: () => controller.candidate.value = null,
                      child: const Text('Hủy')),
                ]),
              TextButton(
                  onPressed:
                      controller.connected.value && !controller.busy.value
                          ? () async {
                              final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                          title: const Text(
                                              'Xóa memory và preference?'),
                                          content: const Text(
                                              'XUNA sẽ bắt đầu học preference lại. Thao tác này không thể hoàn tác.'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(c, false),
                                                child: const Text('Hủy')),
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(c, true),
                                                child: const Text('Xóa'))
                                          ]));
                              if (confirmed == true) await controller.forget();
                            }
                          : null,
                  child: const Text('Xóa memory và preference')),
            ])),
      );
}
