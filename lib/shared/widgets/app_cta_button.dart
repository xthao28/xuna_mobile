import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/app_ink_card.dart';

/// Primary XUNA action: display-font label on a lime ink card, optionally
/// followed by an icon. [onPressed] null disables it.
class AppCtaButton extends StatelessWidget {
  const AppCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.iconAsset,
    this.color = AppColors.xunaLime,
    this.height = AppDimens.buttonHeight,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? iconAsset;
  final Color color;
  final double height;

  /// Hero size used by the home "talk" action.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final icon = iconAsset;
    return AppInkCard(
      color: color,
      radius: large ? AppDimens.radius14 : AppDimens.radius12,
      borderWidth: AppDimens.strokeThick,
      shadow: large ? AppDimens.shadow5 : AppDimens.shadow4,
      enabled: onPressed != null,
      onTap: onPressed ?? () {},
      semanticLabel: label,
      child: SizedBox(
        height: large ? AppDimens.ctaHeight : height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                style: large ? AppTextStyle.display36 : AppTextStyle.display22,
              ),
            ),
            if (icon != null) ...[
              SizedBox(
                  width: large ? AppDimens.padding25 : AppDimens.padding10),
              SvgPicture.asset(
                icon,
                width: large ? AppDimens.padding32 : AppDimens.padding24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
