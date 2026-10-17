import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Static facts about the supported prototype board and protocol.
class HomeDeviceInfoSheet extends StatelessWidget {
  const HomeDeviceInfoSheet({super.key, required this.onClose, this.petId});

  final VoidCallback onClose;

  /// Device-reported PetId, or null when not connected or unsupported.
  final String? petId;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (LocaleKeys.home_infoBoard.tr, LocaleKeys.home_infoBoardValue.tr),
      (LocaleKeys.home_infoMcu.tr, LocaleKeys.home_infoMcuValue.tr),
      (LocaleKeys.home_infoScreen.tr, LocaleKeys.home_infoScreenValue.tr),
      (LocaleKeys.home_infoLink.tr, LocaleKeys.home_infoLinkValue.tr),
      (LocaleKeys.home_infoProtocol.tr, LocaleKeys.home_infoProtocolValue.tr),
      (
        LocaleKeys.home_infoPetId.tr,
        petId == null
            ? LocaleKeys.home_infoPetIdUnavailable.tr
            : '${petId!.substring(0, 8)}…',
      ),
    ];
    return AppSheetFrame(
      eyebrow: LocaleKeys.home_infoEyebrow.tr,
      title: LocaleKeys.home_infoTitle.tr,
      children: [
        AppInkCard(
          shadow: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.padding14,
            vertical: AppDimens.paddingVerySmall,
          ),
          child: Column(
            children: [
              for (final (label, value) in rows)
                AppKeyValueRow(label: label, value: value),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingSmall),
        Text(
          LocaleKeys.home_infoNote.tr,
          style: AppTextStyle.font13Re.copyWith(color: AppColors.xunaInkSoft),
          maxLines: 3,
        ),
        const SizedBox(height: AppDimens.defaultPadding),
        AppBoxButton(label: LocaleKeys.dialog_close.tr, onPressed: onClose),
      ],
    );
  }
}
