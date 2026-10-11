import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xuna_mobile/shared/constants/const_src.dart';
import 'package:xuna_mobile/shared/themes/app_colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UtilWidget {
  static Widget buildLoading({
    Color? colorIcon,
  }) {
    return CupertinoActivityIndicator(
      color: colorIcon ?? AppColors.primaryColor,
    );
  }

  static const Widget shrink = SizedBox.shrink();
  static const Widget sizedBox4 = SizedBox(height: 4);
  static const Widget sizedBox5 = SizedBox(height: 5);
  static const Widget sizedBox8 = SizedBox(height: 8);
  static const Widget sizedBox10 = SizedBox(height: 10);
  static const Widget sizedBox12 = SizedBox(height: 12);
  static const Widget sizedBox16 = SizedBox(height: 16);
  static const Widget sizedBox20 = SizedBox(height: 20);
  static const Widget sizedBox24 = SizedBox(height: 24);
  static const Widget sizedBoxWidth20 = SizedBox(width: 20);
  static const Widget sizedBoxWidth8 = SizedBox(width: 8);
  static const Widget sizedBoxWidth10 = SizedBox(width: 10);
  static const Widget sizedBoxWidth16 = SizedBox(width: 16);

  /// Loading cho child
  static Widget baseShowLoadingChild({
    required WidgetCallback child,
    required bool isShowLoading,
    Color? colorIcon,
  }) {
    return isShowLoading
        ? Center(child: buildLoading(colorIcon: colorIcon))
        : child();
  }

  static Widget buildSmartRefresher({
    required RefreshController refreshController,
    required Widget child,
    ScrollController? scrollController,
    Function()? onRefresh,
    Function()? onLoadMore,
    bool enablePullDown = true,
    bool enablePullUp = false,
  }) {
    return SmartRefresher(
      enablePullDown: enablePullDown,
      enablePullUp: enablePullUp,
      scrollController: scrollController,
      header: const MaterialClassicHeader(
        color: AppColors.primaryColor,
      ),
      controller: refreshController,
      onRefresh: onRefresh,
      onLoading: onLoadMore,
      footer: buildSmartRefresherCustomFooter(),
      child: child,
    );
  }

  static Widget buildSmartRefresherCustomFooter() {
    return CustomFooter(
      builder: (context, mode) {
        if (mode == LoadStatus.loading) {
          return const CupertinoActivityIndicator(
            color: AppColors.primaryColor,
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  static Widget buildCardBase(
    Widget child, {
    Color? colorBorder,
    Color? backgroundColor,
    double? radius,
    Gradient? gradient,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: backgroundColor ?? Colors.white,
          borderRadius:
              BorderRadius.all(Radius.circular(radius ?? AppDimens.radius8)),
          border: Border.all(
            color: colorBorder ?? Colors.transparent,
          ),
        ),
        child: child,
      );

  static Widget buildSolidButton({
    required String title,
    VoidCallback? onPressed,
    double? width,
    double? height,
    double? borderRadius,
    TextStyle? textStyle,
    Color? backgroundColor,
    BorderSide? side,
  }) {
    return SizedBox(
      width: width,
      height: height ?? 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            side: side ?? BorderSide.none,
            borderRadius:
                BorderRadius.circular(borderRadius ?? AppDimens.radius4),
          ),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            title,
            style: textStyle ??
                AppTextStyle.font16Bo.copyWith(color: AppColors.colorWhite),
          ),
        ),
      ),
    );
  }

  static Widget buildBackButton({
    required String title,
    VoidCallback? onPressed,
    double? width,
    double? height,
    double? borderRadius,
    Color? borderColor,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) {
    return SizedBox(
      width: width,
      height: height ?? 44,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.colorWhite,
          side: BorderSide(
            color: borderColor ?? AppColors.primaryColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(borderRadius ?? AppDimens.radius4),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: textStyle ??
              AppTextStyle.font16Bo.copyWith(color: AppColors.primaryColor),
        ),
      ),
    );
  }

  static Widget buildDropdown<T>({
    required List<T> items,
    required String Function(T) display,
    T? selectedItem,
    ValueChanged<T?>? onChanged,
    double height = 50,
    String? hintText,
    double? radius,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.colorWhite,
        borderRadius:
            BorderRadius.all(Radius.circular(radius ?? AppDimens.radius8)),
        border: Border.all(color: AppColors.dsGray4),
      ),
      child: DropdownButtonHideUnderline(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.defaultPadding,
          ),
          child: DropdownButton<T>(
            dropdownColor: AppColors.colorWhite,
            isExpanded: true,
            selectedItemBuilder: (context) => items.map(
              (e) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    display(e),
                    style: AppTextStyle.font14Re,
                    maxLines: 2,
                    textAlign: TextAlign.start,
                  ),
                );
              },
            ).toList(),
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.paddingVerySmall),
                      child: Text(
                        display(e),
                        style: selectedItem == e
                            ? AppTextStyle.font14Bo
                            : AppTextStyle.font14Re,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                      ),
                      //   TextUtils(
                      // text: display(e),
                      // availableStyle: selectedItem == e
                      //     ? StyleEnum.bodyBold
                      //     : StyleEnum.bodyRegular,
                      //   maxLine: 2,
                      //   textAlign: TextAlign.start,
                      // ),
                    ),
                  ),
                )
                .toList(),
            value: selectedItem,
            onChanged: onChanged,
            hint: hintText != null
                ? Text(
                    hintText,
                    style: AppTextStyle.font14Re.copyWith(
                      color: AppColors.dsGray3,
                    ),
                    maxLines: 2,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
