import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/app_ink_card.dart';

/// Compact outlined choice: quick replies (pill) and filters (rounded box).
/// [selected] fills it lime with a shadow. [onPressed] null disables it.
class AppPillButton extends StatelessWidget {
  const AppPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.pill = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;

  /// True: fully rounded quick reply; false: filter box.
  final bool pill;

  @override
  Widget build(BuildContext context) {
    return AppInkCard(
      color: selected ? AppColors.xunaLime : AppColors.xunaCard,
      radius: pill ? AppDimens.radiusPill : AppDimens.radius10,
      borderWidth: pill ? AppDimens.stroke2 : AppDimens.stroke,
      shadow: pill || selected ? AppDimens.shadow2 : 0,
      enabled: onPressed != null,
      onTap: onPressed ?? () {},
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingSmall),
      child: SizedBox(
        height: pill ? AppDimens.padding30 : AppDimens.padding32,
        child: Center(
          widthFactor: 1,
          child: Text(label, style: AppTextStyle.font13Semi),
        ),
      ),
    );
  }
}
