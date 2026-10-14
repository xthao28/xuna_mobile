import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/app_ink_card.dart';

/// Text button in an outlined box: sheet actions and menu rows.
/// [highlighted] uses the lime fill with a shadow. [onPressed] null disables.
class AppBoxButton extends StatelessWidget {
  const AppBoxButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
    this.alignStart = false,
  });

  static const _height = 52.0;

  final String label;
  final VoidCallback? onPressed;
  final bool highlighted;

  /// Left-aligned label for menu rows.
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return AppInkCard(
      color: highlighted ? AppColors.xunaLime : AppColors.xunaCard,
      radius: AppDimens.radius12,
      shadow: highlighted ? AppDimens.shadow3 : 0,
      enabled: onPressed != null,
      onTap: onPressed ?? () {},
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.defaultPadding),
      child: SizedBox(
        height: _height,
        child: Align(
          alignment: alignStart ? Alignment.centerLeft : Alignment.center,
          child: Text(label, style: AppTextStyle.font15Bo),
        ),
      ),
    );
  }
}
