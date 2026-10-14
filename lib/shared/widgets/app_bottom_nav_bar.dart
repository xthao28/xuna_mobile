import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/app_nav_item.dart';

/// Bottom tab bar: the selected item gets a lime pill and a filled icon.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  static const _iconSize = 26.0;

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.xunaPaper,
        border: Border(
          top: BorderSide(color: AppColors.xunaInk, width: AppDimens.stroke),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingSmall,
        AppDimens.paddingVerySmall,
        AppDimens.paddingSmall,
        AppDimens.paddingVerySmall,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(child: _buildItem(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = items[index];
    final active = index == currentIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding3),
      child: Semantics(
        button: true,
        selected: active,
        label: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: AppDimens.navHeight,
            decoration: BoxDecoration(
              color: active ? AppColors.xunaLime : AppColors.colorTransparent,
              borderRadius: BorderRadius.circular(AppDimens.radius12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  active ? item.activeIconAsset : item.iconAsset,
                  width: _iconSize,
                  height: _iconSize,
                ),
                const SizedBox(height: AppDimens.padding3),
                Text(
                  item.label,
                  style: active ? AppTextStyle.font12Bo : AppTextStyle.font12Re,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
