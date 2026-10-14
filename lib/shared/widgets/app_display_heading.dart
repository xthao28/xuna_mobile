import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xuna_mobile/assets.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';

/// Screen title in the display font with the blue pixel sparkle, an optional
/// small mono note on the right and an optional subtitle below.
class AppDisplayHeading extends StatelessWidget {
  const AppDisplayHeading({
    super.key,
    required this.title,
    this.note,
    this.subtitle,
    this.titleStyle,
  });

  static const _noteWidth = 86.0;

  /// May contain line breaks.
  final String title;
  final String? note;
  final String? subtitle;

  /// Defaults to [AppTextStyle.display62].
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final sideNote = note;
    final sub = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The title takes all width left by the note; the sparkle sits
            // right after the text instead of sharing space with a Spacer.
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: titleStyle ?? AppTextStyle.display48,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: AppDimens.padding6),
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimens.padding6),
                    child: SvgPicture.asset(
                      Assets.ASSETS_ICONS_IC_SPARKLE_SVG,
                      width: AppDimens.padding24,
                    ),
                  ),
                ],
              ),
            ),
            if (sideNote != null)
              SizedBox(
                width: _noteWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppDimens.padding10),
                  child: Text(
                    sideNote,
                    style: AppTextStyle.mono10Re,
                    maxLines: 8,
                  ),
                ),
              ),
          ],
        ),
        if (sub != null)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.padding6),
            child: Text(sub, style: AppTextStyle.font17Re, maxLines: 3),
          ),
      ],
    );
  }
}
