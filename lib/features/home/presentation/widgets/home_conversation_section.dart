import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_section_header.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Local text V1: input, reply, confirmation of a feedback candidate and the
/// forget action.
class HomeConversationSection extends StatelessWidget {
  const HomeConversationSection({
    super.key,
    required this.enabled,
    required this.isBusy,
    required this.reply,
    required this.candidate,
    required this.onSubmit,
    required this.onConfirmCandidate,
    required this.onCancelCandidate,
    required this.onForget,
  });

  /// Connected and idle.
  final bool enabled;
  final bool isBusy;
  final String reply;

  /// Feedback awaiting confirmation: true approves, false rejects.
  final bool? candidate;
  final ValueChanged<String> onSubmit;
  final ValueChanged<bool> onConfirmCandidate;
  final VoidCallback onCancelCandidate;
  final VoidCallback onForget;

  @override
  Widget build(BuildContext context) {
    final pendingCandidate = candidate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: LocaleKeys.home_conversationTitle.tr,
          note: LocaleKeys.home_conversationNote.tr,
        ),
        TextField(
          enabled: enabled,
          decoration: InputDecoration(hintText: LocaleKeys.home_textHint.tr),
          textInputAction: TextInputAction.send,
          onSubmitted: onSubmit,
        ),
        UtilWidget.sizedBox8,
        Text(reply, style: AppTextStyle.font14Re, maxLines: 5),
        if (pendingCandidate != null)
          Wrap(
            spacing: AppDimens.paddingVerySmall,
            children: [
              FilledButton(
                onPressed:
                    isBusy ? null : () => onConfirmCandidate(pendingCandidate),
                child: Text(LocaleKeys.home_confirmFeedback.tr),
              ),
              TextButton(
                onPressed: onCancelCandidate,
                child: Text(LocaleKeys.dialog_cancel.tr),
              ),
            ],
          ),
        TextButton(
          onPressed: enabled ? onForget : null,
          child: Text(LocaleKeys.home_forget.tr),
        ),
      ],
    );
  }
}
