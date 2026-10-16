import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_pet_scene.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Drawing of the LILYGO board whose little screen mirrors the connection.
class HomeBoardIllustration extends StatelessWidget {
  const HomeBoardIllustration({
    super.key,
    required this.connected,
    required this.animation,
    required this.isBusy,
    required this.statusColor,
  });

  static const _boardWidth = 236.0;
  static const _boardHeight = 122.0;
  static const _screenWidth = 160.0;
  static const _screenHeight = 90.0;
  static const _buttonWidth = 22.0;
  static const _buttonHeight = 12.0;
  static const _floorHeight = 46.0;
  static const _dotSize = 20.0;

  final bool connected;
  final AnimationState animation;
  final bool isBusy;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.xunaLilac,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(
          color: AppColors.xunaInk,
          width: AppDimens.strokeThick,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _floorHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.xunaLilacDeep,
                border: Border(
                  top: BorderSide(
                    color: AppColors.xunaInk,
                    width: AppDimens.strokeThick,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppDimens.padding14,
            top: AppDimens.paddingSmall,
            child: AppTag(
              text: LocaleKeys.home_boardName.tr,
              color: AppColors.xunaCard,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              AppDimens.padding40,
              0,
              AppDimens.padding30,
            ),
            child: Center(child: _buildBoard()),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() => SizedBox(
        width: _boardWidth + AppDimens.paddingSmall,
        height: _boardHeight + AppDimens.paddingSmall,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: AppDimens.paddingSmall,
              top: AppDimens.paddingSmall,
              child: Container(
                width: _boardWidth,
                height: _boardHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppColors.xunaBoard,
                  borderRadius: BorderRadius.circular(AppDimens.radius12),
                  border: Border.all(
                    color: AppColors.xunaInk,
                    width: AppDimens.strokeThick,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.xunaInk,
                      offset: Offset(AppDimens.shadow6, AppDimens.shadow6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildScreen(),
                    const SizedBox(width: AppDimens.paddingSmall),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _boardButton(),
                        const SizedBox(height: AppDimens.padding14),
                        _boardButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: AppStatusDot(
                color: statusColor,
                blinking: isBusy && !connected,
                size: _dotSize,
                borderWidth: AppDimens.strokeThick,
              ),
            ),
          ],
        ),
      );

  Widget _buildScreen() {
    final Widget content;
    if (connected) {
      content = HomePetScene(animation: animation, connected: connected);
    } else {
      content = Center(
        child: Text(
          isBusy
              ? LocaleKeys.home_screenSearching.tr
              : LocaleKeys.home_screenSleeping.tr,
          style: AppTextStyle.mono10Bo.copyWith(
            color: isBusy ? AppColors.xunaLime : AppColors.xunaInkDisabled,
          ),
        ),
      );
    }
    return Container(
      width: _screenWidth,
      height: _screenHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.xunaBoardScreen,
        borderRadius: BorderRadius.circular(AppDimens.radius4),
        border: Border.all(
          color: AppColors.xunaInk,
          width: AppDimens.strokeThick,
        ),
      ),
      child: content,
    );
  }

  static Widget _boardButton() => Container(
        width: _buttonWidth,
        height: _buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.xunaLime,
          borderRadius: BorderRadius.circular(AppDimens.padding3),
          border:
              Border.all(color: AppColors.xunaInk, width: AppDimens.stroke2),
        ),
      );
}
