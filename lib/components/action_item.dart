import 'package:flutter/material.dart';

import '../constants/color_constant.dart';
import '../constants/font_constant.dart';

class KaireteActionItem extends StatelessWidget {
  const KaireteActionItem(
      {Key? key,
      this.title,
      this.subTitle,
      required this.onTap,
      this.content,
      this.subTitleColor,
      this.titleStyle,
      this.contentStyle,
      this.subTitleStyle,
      this.isShowArrow = true,
      this.isHaveBorder = false,
      this.customRightView,
      this.isActive = false,
      this.margin,
      this.suffixIcon,
      this.background})
      : super(key: key);

  final String? title;
  final String? subTitle;
  final Function onTap;
  final String? content;
  final Color? subTitleColor;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final TextStyle? subTitleStyle;

  final bool isShowArrow;
  final bool isHaveBorder;
  final Widget? customRightView;
  final bool isActive;
  final EdgeInsetsGeometry? margin;
  final Widget? suffixIcon;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: margin,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: background ?? Colors.white,
            border: Border.all(
                width: 1,
                color: isHaveBorder
                    ? (isActive ? kTextPrimaryColor : kBorderDefaultColor)
                    : Colors.transparent)),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (suffixIcon != null) suffixIcon!,
                      if (suffixIcon != null)
                        const SizedBox(
                          width: 16,
                        ),
                      Text(
                        title ?? 'Cài đặt bảo mật',
                        style: titleStyle ??
                            kTextRegularStyle.copyWith(color: kTextMediumColor),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      subTitle ?? '',
                      style: subTitleStyle ??
                          kTextRegularStyle.copyWith(color: subTitleColor),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    // if (isShowArrow)
                    //   const SvgIcon(
                    //     name: 'ic_arrow_right',
                    //     leftPadding: 0,
                    //   ),
                    if (customRightView != null) customRightView!,
                  ],
                )
              ],
            ),
            if (content != null)
              Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    content!,
                    style: contentStyle ??
                        kTextRegularStyle.copyWith(color: kTextMediumColor),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
