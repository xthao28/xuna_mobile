import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/features/home/presentation/controller/home_controller.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_chat_bubble.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_chat_composer.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// "Trò chuyện" tab: local text V1 conversation with XUNA.
class HomeChatTab extends StatelessWidget {
  const HomeChatTab({
    super.key,
    required this.messages,
    required this.connected,
    required this.isBusy,
    required this.candidate,
    required this.onBack,
    required this.onMenu,
    required this.onSubmit,
    required this.onConfirmCandidate,
    required this.onCancelCandidate,
    required this.onComingSoon,
  });

  static const _heroWidth = 100.0;
  static const _heroHeight = 80.0;
  static const _sideNoteWidth = 56.0;

  /// Oldest first.
  final List<HomeChatMessage> messages;
  final bool connected;
  final bool isBusy;
  final bool? candidate;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final ValueChanged<String> onSubmit;
  final ValueChanged<bool> onConfirmCandidate;
  final VoidCallback onCancelCandidate;
  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding6),
          child: Row(
            children: [
              _iconButton(
                Assets.ASSETS_ICONS_IC_CHEVRON_LEFT_SVG,
                LocaleKeys.home_back.tr,
                onBack,
              ),
              const Spacer(),
              _iconButton(
                Assets.ASSETS_ICONS_IC_MORE_SVG,
                LocaleKeys.home_menu.tr,
                onMenu,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDisplayHeading(title: LocaleKeys.home_chatTitle.tr),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppDimens.padding10),
                      child: Text(
                        LocaleKeys.home_chatNote.tr,
                        style: AppTextStyle.mono11Re,
                        maxLines: 3,
                      ),
                    ),
                  ),
                  Image.asset(
                    Assets.ASSETS_IMAGES_HERO_PNG,
                    width: _heroWidth,
                    height: _heroHeight,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                  ),
                  SizedBox(
                    width: _sideNoteWidth,
                    child: Text(
                      LocaleKeys.home_chatSideNote.tr,
                      style: AppTextStyle.mono10Bo,
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(
              AppDimens.padding18,
              AppDimens.padding6,
              AppDimens.padding18,
              AppDimens.paddingVerySmall,
            ),
            itemCount: messages.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimens.paddingSmall),
            itemBuilder: (context, index) {
              final message = messages[messages.length - 1 - index];
              return HomeChatBubble(
                text: message.text,
                time: _clock(message.at),
                fromXuna: message.fromXuna,
              );
            },
          ),
        ),
        HomeChatComposer(
          isBusy: isBusy,
          candidate: candidate,
          onSubmit: onSubmit,
          onConfirmCandidate: onConfirmCandidate,
          onCancelCandidate: onCancelCandidate,
          onComingSoon: onComingSoon,
        ),
      ],
    );
  }

  static Widget _iconButton(String asset, String label, VoidCallback onTap) =>
      Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: onTap,
          child: SizedBox(
            width: AppDimens.touchTarget,
            height: AppDimens.touchTarget,
            child: Center(
              child: SvgPicture.asset(asset, width: AppDimens.padding24),
            ),
          ),
        ),
      );

  static String _clock(DateTime at) => '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';
}
