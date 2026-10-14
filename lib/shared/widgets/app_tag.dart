import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';

/// Small outlined label: activity chips, provenance tags, "coming soon".
class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.text,
    this.color = AppColors.xunaCard,
    this.style,
    this.iconAsset,
    this.outlined = true,
  });

  final String text;
  final Color color;

  /// Defaults to the bold mono label style.
  final TextStyle? style;
  final String? iconAsset;

  /// False draws a filled tag without an outline (journal entry tags).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final icon = iconAsset;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingVerySmall,
        vertical: AppDimens.paddingSmallest,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimens.radius8),
        border: outlined
            ? Border.all(color: AppColors.xunaInk, width: AppDimens.stroke2)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(icon, height: AppDimens.padding15),
            const SizedBox(width: AppDimens.padding6),
          ],
          Flexible(child: Text(text, style: style ?? AppTextStyle.mono9Bo)),
        ],
      ),
    );
  }
}
