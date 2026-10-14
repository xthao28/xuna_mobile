import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/features/device/domain/entity/animation_state.dart';
import 'package:xuna_mobile/features/device/domain/entity/memory_episode.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_journal_entry.dart';
import 'package:xuna_mobile/features/home/presentation/widgets/home_room_card.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// "Nhà" tab: brand header, connection shortcut, XUNA's room, the talk
/// action and the most recent memory.
class HomeOverviewTab extends StatelessWidget {
  const HomeOverviewTab({
    super.key,
    required this.isSimulator,
    required this.connected,
    required this.isBusy,
    required this.animation,
    required this.latestMemory,
    required this.onConnection,
    required this.onPoke,
    required this.onTalk,
    required this.onJournal,
    required this.onComingSoon,
  });

  static const connectionKey = Key('home.connection');
  static const _bookSize = 60.0;

  final bool isSimulator;
  final bool connected;
  final bool isBusy;
  final AnimationState animation;
  final MemoryEpisode? latestMemory;
  final VoidCallback onConnection;
  final VoidCallback onPoke;
  final VoidCallback onTalk;
  final VoidCallback onJournal;
  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.padding18,
        AppDimens.paddingSmallest,
        AppDimens.padding18,
        AppDimens.padding22,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  LocaleKeys.app_name.tr,
                  style: AppTextStyle.display112,
                ),
              ),
            ),
            const SizedBox(width: AppDimens.paddingSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInkCard(
                  key: connectionKey,
                  radius: AppDimens.radius10,
                  shadow: AppDimens.shadow3,
                  onTap: onConnection,
                  semanticLabel: _connectionLabel(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingSmall,
                    vertical: AppDimens.paddingVerySmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppStatusDot(
                        color: _connectionColor(),
                        blinking: isBusy && !connected,
                      ),
                      const SizedBox(width: AppDimens.padding6),
                      Text(_connectionLabel(), style: AppTextStyle.font13Semi),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingSmall),
                Text(
                  LocaleKeys.home_tagline.tr,
                  style: AppTextStyle.mono10Re,
                  maxLines: 3,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingSmall),
        HomeRoomCard(
          isSimulator: isSimulator,
          connected: connected,
          animation: animation,
          onPoke: onPoke,
          onComingSoon: onComingSoon,
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        AppDisplayHeading(
          title: LocaleKeys.home_greeting.tr,
          subtitle: LocaleKeys.home_greetingSub.tr,
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        AppCtaButton(
          label: LocaleKeys.home_talk.tr,
          iconAsset: Assets.ASSETS_ICONS_IC_ARROW_RIGHT_SVG,
          large: true,
          onPressed: onTalk,
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        AppInkCard(
          onTap: onJournal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding14,
            vertical: AppDimens.paddingSmall,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                Assets.ASSETS_ICONS_IC_BOOK_PIXEL_SVG,
                width: _bookSize,
              ),
              const SizedBox(width: AppDimens.padding14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.home_latestMemoryTitle.tr,
                      style: AppTextStyle.display19,
                    ),
                    const SizedBox(height: AppDimens.paddingSmallest),
                    Text(
                      _memoryLine(),
                      style: AppTextStyle.font13Re,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SvgPicture.asset(
                Assets.ASSETS_ICONS_IC_CHEVRON_RIGHT_SVG,
                width: AppDimens.padding22,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _connectionLabel() {
    if (connected) return LocaleKeys.home_connOnline.tr;
    if (isBusy) return LocaleKeys.home_connBusy.tr;
    return LocaleKeys.home_connOffline.tr;
  }

  Color _connectionColor() {
    if (connected) return AppColors.xunaOnline;
    if (isBusy) return AppColors.xunaConnecting;
    return AppColors.xunaOffline;
  }

  String _memoryLine() {
    final memory = latestMemory;
    if (!connected) return LocaleKeys.home_latestMemoryOffline.tr;
    if (memory == null) return LocaleKeys.home_latestMemoryEmpty.tr;
    return HomeJournalEntry.memoryTitle(memory);
  }
}
