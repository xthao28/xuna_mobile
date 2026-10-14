import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// XUNA's pixel room. The activity chip and the reaction bubble mirror the
/// animation reported by the device; growth is shown as not built yet.
class HomeRoomCard extends StatelessWidget {
  const HomeRoomCard({
    super.key,
    required this.isSimulator,
    required this.connected,
    required this.animation,
    required this.onPoke,
    required this.onComingSoon,
  });

  static const activityKey = Key('home.activity');
  static const _aspectRatio = 417 / 360;

  final bool isSimulator;
  final bool connected;
  final AnimationState animation;
  final VoidCallback onPoke;
  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    final happy = connected && animation == AnimationState.happy;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.xunaRoom,
        borderRadius: BorderRadius.circular(AppDimens.radius16),
        border: Border.all(
          color: AppColors.xunaInk,
          width: AppDimens.strokeThick,
        ),
      ),
      child: AspectRatio(
        aspectRatio: _aspectRatio,
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  Assets.ASSETS_IMAGES_RAIN_PNG,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                ),
              ),
              Positioned(
                left: AppDimens.paddingVerySmall,
                top: AppDimens.paddingVerySmall,
                child: _GrowthBadge(onTap: onComingSoon),
              ),
              Positioned(
                left: box.maxWidth * 0.22,
                top: box.maxHeight * 0.42,
                width: box.maxWidth * 0.4,
                height: box.maxHeight * 0.5,
                child: Semantics(
                  button: true,
                  label: LocaleKeys.home_pokeHint.tr,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onPoke,
                  ),
                ),
              ),
              if (happy) ...[
                Positioned(
                  left: box.maxWidth * 0.44,
                  top: box.maxHeight * 0.22,
                  child: IgnorePointer(
                    child: AppInkCard(
                      radius: AppDimens.radius14,
                      shadow: AppDimens.shadow3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingSmall,
                        vertical: AppDimens.padding6,
                      ),
                      child: Text(
                        LocaleKeys.home_reactHappy.tr,
                        style: AppTextStyle.font14Bo,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: box.maxWidth * 0.3,
                  top: box.maxHeight * 0.46,
                  child:
                      SvgPicture.asset(Assets.ASSETS_ICONS_IC_HEART_PIXEL_SVG),
                ),
              ],
              Positioned(
                left: AppDimens.paddingVerySmall,
                right: AppDimens.paddingVerySmall,
                bottom: AppDimens.paddingVerySmall,
                child: Row(
                  children: [
                    Flexible(
                      child: AppTag(
                        key: activityKey,
                        text: _activity(),
                      ),
                    ),
                    const Spacer(),
                    if (isSimulator)
                      AppTag(
                        text: LocaleKeys.home_sourceSimulator.tr,
                        color: AppColors.xunaLime,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _activity() {
    if (!connected) return LocaleKeys.home_activityOffline.tr;
    return switch (animation) {
      AnimationState.idle => LocaleKeys.home_activityIdle.tr,
      AnimationState.happy => LocaleKeys.home_activityHappy.tr,
      AnimationState.sleep => LocaleKeys.home_activitySleep.tr,
      AnimationState.curious => LocaleKeys.home_activityCurious.tr,
    };
  }
}

/// Placeholder for the growth level: no level exists before M06.
class _GrowthBadge extends StatelessWidget {
  const _GrowthBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.padding10,
          AppDimens.paddingVerySmall,
          AppDimens.padding10,
          AppDimens.paddingVerySmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.xunaInk,
          borderRadius: BorderRadius.circular(AppDimens.radius9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.home_growthLabel.tr,
              style: AppTextStyle.mono15Bo.copyWith(color: AppColors.xunaPaper),
            ),
            const SizedBox(height: AppDimens.padding5),
            Text(
              LocaleKeys.home_comingSoon.tr,
              style: AppTextStyle.mono9Bo.copyWith(color: AppColors.xunaLime),
            ),
          ],
        ),
      ),
    );
  }
}
