import 'package:flutter/material.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';

/// Title and explanatory note of a home section.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.note,
  });

  final String title;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyle.font20Bo),
        Text(note, style: AppTextStyle.font14Re, maxLines: 3),
      ],
    );
  }
}
