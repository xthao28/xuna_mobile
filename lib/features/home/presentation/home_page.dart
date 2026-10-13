import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/core/presentation/widgets/base_get_page.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_choice_section.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_connection_section.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_conversation_section.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';

class HomePage extends BaseGetPage<HomeController> {
  HomePage({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.app_name.tr, style: AppTextStyle.font18Bo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.padding24),
        children: [
          Obx(
            () => HomeConnectionSection(
              isSimulator: controller.isSimulator,
              message: controller.message.value,
              isBusy: controller.isBusy,
              connected: controller.connected.value,
              animation: controller.animation.value,
              devices: controller.devices.toList(),
              onScan: controller.scan,
              onConnect: controller.connect,
              onAnimation: controller.setAnimation,
              onDisconnect: controller.disconnect,
            ),
          ),
          const Divider(),
          Obx(
            () => HomeChoiceSection(
              enabled: controller.connected.value && !controller.isBusy,
              life: controller.life.value,
              memories: controller.memories.toList(),
              onSuggest: controller.suggest,
              onFeedback: controller.feedback,
            ),
          ),
          const Divider(),
          Obx(
            () => HomeConversationSection(
              enabled: controller.connected.value && !controller.isBusy,
              isBusy: controller.isBusy,
              reply: controller.reply.value,
              candidate: controller.candidate.value,
              onSubmit: controller.submitText,
              onConfirmCandidate: (approved) =>
                  controller.feedback(approved, fromText: true),
              onCancelCandidate: controller.cancelCandidate,
              onForget: controller.requestForget,
            ),
          ),
        ],
      ),
    );
  }
}
