import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Conversation options: restart the on-screen chat or open the journal.
class HomeChatMenuSheet extends StatelessWidget {
  const HomeChatMenuSheet({
    super.key,
    required this.onRestart,
    required this.onJournal,
    required this.onClose,
  });

  final VoidCallback onRestart;
  final VoidCallback onJournal;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppSheetFrame(
      title: LocaleKeys.home_chatMenuTitle.tr,
      children: [
        AppBoxButton(
          label: LocaleKeys.home_chatMenuRestart.tr,
          onPressed: onRestart,
          alignStart: true,
        ),
        const SizedBox(height: AppDimens.padding10),
        AppBoxButton(
          label: LocaleKeys.home_chatMenuJournal.tr,
          onPressed: onJournal,
          alignStart: true,
        ),
        const SizedBox(height: AppDimens.padding10),
        AppBoxButton(
          label: LocaleKeys.dialog_close.tr,
          onPressed: onClose,
          highlighted: true,
        ),
      ],
    );
  }
}
