import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/generated/locales.g.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:xuna_mobile/shared/widgets/widget_src.dart';

/// Optional XUNA Cloud account on the device tab. Pet life never depends on it.
class HomeAccountCard extends StatelessWidget {
  const HomeAccountCard({
    super.key,
    required this.accountName,
    required this.isBusy,
    required this.onSignIn,
    required this.onSignOut,
    required this.onCheckCloud,
  });

  /// Email or display name when signed in, null when signed out.
  final String? accountName;
  final bool isBusy;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onCheckCloud;

  @override
  Widget build(BuildContext context) {
    final name = accountName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(LocaleKeys.account_title.tr, style: AppTextStyle.display19),
        const SizedBox(height: AppDimens.paddingVerySmall),
        AppInkCard(
          padding: const EdgeInsets.all(AppDimens.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                name == null
                    ? LocaleKeys.account_signedOut.tr
                    : LocaleKeys.account_signedInAs.trParams({'name': name}),
                style: AppTextStyle.font14Semi,
                maxLines: 2,
              ),
              const SizedBox(height: AppDimens.padding6),
              Text(
                LocaleKeys.account_note.tr,
                style: AppTextStyle.font13Re
                    .copyWith(color: AppColors.xunaInkMuted),
                maxLines: 3,
              ),
              const SizedBox(height: AppDimens.paddingSmall),
              if (name == null)
                AppBoxButton(
                  label: LocaleKeys.account_signIn.tr,
                  onPressed: isBusy ? null : onSignIn,
                )
              else ...[
                AppBoxButton(
                  label: LocaleKeys.account_checkCloud.tr,
                  onPressed: isBusy ? null : onCheckCloud,
                ),
                const SizedBox(height: AppDimens.paddingVerySmall),
                AppBoxButton(
                  label: LocaleKeys.account_signOut.tr,
                  onPressed: isBusy ? null : onSignOut,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
