import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// One conversation line: XUNA on the left with its avatar, the owner on the
/// right in lilac. [time] is shown under the bubble.
class HomeChatBubble extends StatelessWidget {
  const HomeChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.fromXuna,
  });

  static const _avatarSize = 46.0;
  static const _xunaWidthFactor = 0.88;
  static const _ownerWidthFactor = 0.82;

  final String text;
  final String time;
  final bool fromXuna;

  @override
  Widget build(BuildContext context) {
    final bubble = AppInkCard(
      color: fromXuna ? AppColors.xunaCard : AppColors.xunaLilac,
      radius: AppDimens.radius18,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.defaultPadding,
        vertical: AppDimens.padding10,
      ),
      child: Text(text, style: AppTextStyle.font16Body, maxLines: 12),
    );
    final stamp = Text(
      time,
      style: AppTextStyle.mono10Re.copyWith(color: AppColors.xunaInkSoft),
    );
    return LayoutBuilder(
      builder: (context, box) {
        if (!fromXuna) {
          return Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: box.maxWidth * _ownerWidthFactor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  bubble,
                  const SizedBox(height: AppDimens.paddingSmallest),
                  stamp,
                ],
              ),
            ),
          );
        }
        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: box.maxWidth * _xunaWidthFactor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ClipOval(
                  child: ColoredBox(
                    color: AppColors.xunaCardPressed,
                    child: AppXunaPet(
                      width: _avatarSize,
                      height: _avatarSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.padding10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bubble,
                      const SizedBox(height: AppDimens.paddingSmallest),
                      stamp,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
