import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';

/// Paper bottom sheet with an ink top edge, grab handle, optional mono
/// [eyebrow] and display [title]. Open it with `nav.bottomSheet`.
class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({
    super.key,
    required this.children,
    this.eyebrow,
    this.title,
  });

  static const _handleWidth = 44.0;
  static const _handleHeight = 5.0;
  static const _maxHeightFactor = 0.82;

  final List<Widget> children;
  final String? eyebrow;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final label = eyebrow;
    final heading = title;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.xunaPaper,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radius26),
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.xunaInk,
              width: AppDimens.strokeThick,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingMedium,
              AppDimens.padding10,
              AppDimens.paddingMedium,
              AppDimens.padding24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: _handleWidth,
                    height: _handleHeight,
                    decoration: BoxDecoration(
                      color: AppColors.xunaInk,
                      borderRadius: BorderRadius.circular(AppDimens.radius4),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.padding14),
                if (label != null) Text(label, style: AppTextStyle.mono11Re),
                if (heading != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimens.paddingSmallest,
                      bottom: AppDimens.paddingSmall,
                    ),
                    child: Text(
                      heading,
                      style: AppTextStyle.display30,
                      maxLines: 2,
                    ),
                  ),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
