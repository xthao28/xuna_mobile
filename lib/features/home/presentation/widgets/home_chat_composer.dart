import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Bottom of the chat: quick replies, the feedback confirmation bar, the
/// voice button (not built yet) and the text input.
class HomeChatComposer extends StatefulWidget {
  const HomeChatComposer({
    super.key,
    required this.isBusy,
    required this.candidate,
    required this.onSubmit,
    required this.onConfirmCandidate,
    required this.onCancelCandidate,
    required this.onComingSoon,
  });

  static const inputKey = Key('home.chatInput');
  static const sendKey = Key('home.chatSend');
  static const _micSize = 96.0;
  static const _sideNoteWidth = 96.0;

  final bool isBusy;

  /// Feedback awaiting confirmation: true approves, false rejects.
  final bool? candidate;
  final ValueChanged<String> onSubmit;
  final ValueChanged<bool> onConfirmCandidate;
  final VoidCallback onCancelCandidate;
  final VoidCallback onComingSoon;

  @override
  State<HomeChatComposer> createState() => _HomeChatComposerState();
}

class _HomeChatComposerState extends State<HomeChatComposer> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    _input.addListener(_onInput);
  }

  void _onInput() => setState(() {});

  @override
  void dispose() {
    _input
      ..removeListener(_onInput)
      ..dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty || widget.isBusy) return;
    widget.onSubmit(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    final prompts = [
      LocaleKeys.home_promptPlay.tr,
      LocaleKeys.home_promptQuiet.tr,
      LocaleKeys.home_promptLike.tr,
      LocaleKeys.home_promptDislike.tr,
    ];
    final pending = widget.candidate;
    final hasDraft = _input.text.trim().isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(
            AppDimens.padding18,
            AppDimens.paddingSmallest,
            AppDimens.padding18,
            AppDimens.paddingVerySmall,
          ),
          child: Row(
            children: [
              for (final prompt in prompts)
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimens.paddingVerySmall,
                  ),
                  child: AppPillButton(
                    label: prompt,
                    onPressed: widget.isBusy ? null : () => _send(prompt),
                  ),
                ),
            ],
          ),
        ),
        if (pending != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.padding18,
              AppDimens.paddingSmallest,
              AppDimens.padding18,
              AppDimens.paddingVerySmall,
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppBoxButton(
                    label: LocaleKeys.home_confirmFeedback.tr,
                    highlighted: true,
                    onPressed: widget.isBusy
                        ? null
                        : () => widget.onConfirmCandidate(pending),
                  ),
                ),
                const SizedBox(width: AppDimens.padding10),
                AppBoxButton(
                  label: LocaleKeys.dialog_cancel.tr,
                  onPressed: widget.onCancelCandidate,
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  LocaleKeys.home_voiceHint.tr,
                  style: AppTextStyle.mono10Re,
                  maxLines: 5,
                ),
              ),
              _buildMic(),
              SizedBox(
                width: HomeChatComposer._sideNoteWidth,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppDimens.paddingSmall),
                  child: Text(
                    LocaleKeys.home_voiceSoon.tr,
                    style: AppTextStyle.mono10Bo,
                    maxLines: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.padding18,
            AppDimens.padding6,
            AppDimens.padding18,
            AppDimens.paddingSmall,
          ),
          child: Row(
            children: [
              _SquareButton(
                iconAsset: Assets.ASSETS_ICONS_IC_IMAGE_SVG,
                label: LocaleKeys.home_attachImage.tr,
                dimmed: true,
                onTap: widget.onComingSoon,
              ),
              const SizedBox(width: AppDimens.padding10),
              Expanded(
                child: TextField(
                  key: HomeChatComposer.inputKey,
                  controller: _input,
                  style: AppTextStyle.font16Body,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _send,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.home_textHint.tr,
                    hintStyle: AppTextStyle.font16Body
                        .copyWith(color: AppColors.xunaInkDisabled),
                    filled: true,
                    fillColor: AppColors.xunaCard,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.defaultPadding,
                      vertical: AppDimens.padding14,
                    ),
                    enabledBorder: _border(),
                    focusedBorder: _border(),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.padding10),
              _SquareButton(
                key: HomeChatComposer.sendKey,
                iconAsset: Assets.ASSETS_ICONS_IC_SEND_SVG,
                label: LocaleKeys.home_send.tr,
                color: hasDraft ? AppColors.xunaLime : AppColors.xunaCard,
                onTap: widget.isBusy ? null : () => _send(_input.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMic() => Semantics(
        button: true,
        enabled: false,
        label: LocaleKeys.home_voiceSoon.tr,
        child: GestureDetector(
          onTap: widget.onComingSoon,
          child: Opacity(
            opacity: 0.5,
            child: Container(
              width: HomeChatComposer._micSize,
              height: HomeChatComposer._micSize,
              decoration: const BoxDecoration(
                color: AppColors.xunaLime,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(
                    color: AppColors.xunaInk,
                    width: AppDimens.strokeThick,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.xunaInk,
                    offset: Offset(AppDimens.shadow5, AppDimens.shadow5),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                Assets.ASSETS_ICONS_IC_MIC_SVG,
                height: AppDimens.padding50,
              ),
            ),
          ),
        ),
      );

  static OutlineInputBorder _border() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        borderSide: const BorderSide(
          color: AppColors.xunaInk,
          width: AppDimens.stroke,
        ),
      );
}

/// Square icon action beside the chat input.
class _SquareButton extends StatelessWidget {
  const _SquareButton({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.color = AppColors.xunaCard,
    this.dimmed = false,
  });

  final String iconAsset;
  final String label;
  final VoidCallback? onTap;
  final Color color;

  /// Shown faded for a feature that is not built yet; still tappable.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: AppInkCard(
        color: color,
        radius: AppDimens.radius11,
        shadow: dimmed ? 0 : AppDimens.shadow3,
        enabled: onTap != null,
        onTap: onTap ?? () {},
        semanticLabel: label,
        child: SizedBox(
          width: AppDimens.inputHeight,
          height: AppDimens.inputHeight,
          child: Center(
            child: SvgPicture.asset(iconAsset, width: AppDimens.padding22),
          ),
        ),
      ),
    );
  }
}
