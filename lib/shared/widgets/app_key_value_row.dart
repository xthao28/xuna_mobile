import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';

/// Muted label on the left, bold value on the right.
class AppKeyValueRow extends StatelessWidget {
  const AppKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.valueKey,
  });

  final String label;
  final String value;

  /// Lets tests find the value text.
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.padding3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                AppTextStyle.font14Re.copyWith(color: AppColors.xunaInkMuted),
          ),
          const SizedBox(width: AppDimens.padding14),
          Expanded(
            child: Text(
              value,
              key: valueKey,
              style: AppTextStyle.font14Bo,
              textAlign: TextAlign.right,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
