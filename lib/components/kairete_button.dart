import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/constants/color.dart';

import '../constants/color_constant.dart';
import '../constants/font_constant.dart';

class KairetePrimaryButton extends StatelessWidget {
  const KairetePrimaryButton({
    Key? key,
    this.height,
    this.width,
    this.title,
    this.state = StateButton.active,
    required this.onTap,
    this.customContent,
    this.color,
    this.titleColor,
  }) : super(key: key);

  final double? height;
  final double? width;
  final String? title;
  final StateButton state;
  final Function onTap;
  final Widget? customContent;
  final Color? color;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state != StateButton.disable) {
          FocusScope.of(Get.context ?? context).unfocus();
          onTap();
        }
      },
      child: Container(
        height: height ?? 48,
        width: width ?? 1.sw,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color ?? getBackgroundColor(state)),
        child: Center(
          child: customContent ??
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: kTextButtonStyle.copyWith(
                    color: titleColor ?? getTitleColor(state)),
              ),
        ),
      ),
    );
  }

  Color getBackgroundColor(StateButton state) {
    switch (state) {
      case StateButton.active:
        return kSurfacePrimaryColor;
      case StateButton.pressed:
        return kSurfaceMediumColor;
      default:
        return Colors.transparent;
    }
  }

  Color getTitleColor(StateButton state) {
    switch (state) {
      case StateButton.disable:
        return kTextDisabledColor;
      default:
        return Colors.white;
    }
  }
}

enum StateButton { active, pressed, disable }

class KaireteActionButton extends StatelessWidget {
  const KaireteActionButton({
    Key? key,
    this.height,
    this.width,
    this.title,
    required this.onTap,
    this.backgroundColor,
    this.titleColor,
    this.prefixIcon,
    this.padding,
  }) : super(key: key);

  final double? height;
  final double? width;
  final String? title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Function onTap;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        height: padding != null ? null : height ?? 48,
        width: width,
        padding: padding,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor ?? kSurfacePrimaryColor),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (prefixIcon != null) prefixIcon!,
              if (prefixIcon != null)
                const SizedBox(
                  width: 16,
                ),
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: kTextButtonStyle.copyWith(
                    color: titleColor ?? Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KaireteSecondaryButton extends StatelessWidget {
  const KaireteSecondaryButton({
    Key? key,
    this.height,
    this.width,
    this.title,
    this.state = StateButton.active,
    required this.onTap,
  }) : super(key: key);

  final double? height;
  final double? width;
  final String? title;
  final StateButton state;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (state != StateButton.disable) {
          onTap();
        }
      },
      child: Container(
        height: height ?? 56,
        width: width ?? 1.sw,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: getBackgroundColor(state)),
        child: Center(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: kTextButtonStyle.copyWith(color: getTitleColor(state)),
          ),
        ),
      ),
    );
  }

  Color getBackgroundColor(StateButton state) {
    switch (state) {
      case StateButton.active:
        return kSurfacePrimarySubdueColor;
      case StateButton.pressed:
        return kSurfacePrimarySubdueColor;
      default:
        return kSurfaceDisabledColor;
    }
  }

  Color getTitleColor(StateButton state) {
    switch (state) {
      case StateButton.disable:
        return kTextDisabledColor;
      default:
        return kTextPrimaryColor;
    }
  }
}

class KaireteTextButton extends StatelessWidget {
  const KaireteTextButton({
    Key? key,
    this.height,
    this.width,
    this.title,
    required this.onTap,
    this.color,
    this.textAlign,
    this.isCenter = false,
    this.leftIcon,
    this.style,
    this.backgroundColor,
  }) : super(key: key);

  final double? height;
  final double? width;
  final String? title;
  final Color? color;
  final TextAlign? textAlign;
  final Function onTap;
  final bool isCenter;
  final Widget? leftIcon;
  final TextStyle? style;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        color: backgroundColor,
        height: height ?? 24,
        width: width ?? 1.sw,
        child: isCenter
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  leftIcon ?? const SizedBox(),
                  Center(
                    child: Text(
                      title ?? '',
                      textAlign: textAlign ?? TextAlign.right,
                      style: style ??
                          kTextButtonStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color ?? kTextPrimaryColor),
                    ),
                  ),
                ],
              )
            : Text(
                title ?? '',
                textAlign: textAlign ?? TextAlign.right,
                style: style ??
                    kTextButtonStyle.copyWith(
                        color: color ?? kTextPrimaryColor),
              ),
      ),
    );
  }
}

class SocicalButton extends StatelessWidget {
  const SocicalButton(
      {Key? key, this.icon, this.height, this.width, this.onTap})
      : super(key: key);

  final Widget? icon;
  final double? height;
  final double? width;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        height: height ?? 48.h,
        width: width ?? 69.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: Center(child: icon),
      ),
    );
  }
}

class WatchButton extends StatelessWidget {
  final Function onTap;

  const WatchButton({
    super.key,
    required this.isWatched,
    required this.onTap,
    this.padding,
    this.icon,
  });

  final bool isWatched;
  final EdgeInsets? padding;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: padding ??
            EdgeInsets.only(
              top: 8,
              bottom: 8,
            ),
        // child: KaireteActionButton(
        //   onTap: onTap,
        //   title: isWatched ? 'Unwatch' : 'Watch',
        //   padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        // ),
        child: Container(
          child: SvgIcon(
            name: icon ?? 'ic_follow',
            color: isWatched ? kPrimaryColor : Colors.black,
          ),
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.onTap,
    this.padding,
    this.icon,
    this.isActive,
  });

  final String title;
  final Function onTap;
  final EdgeInsets? padding;
  final String? icon;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: padding ?? EdgeInsets.only(top: 8, bottom: 8),
        // child: KaireteActionButton(
        //   onTap: onTap,
        //   title: title,
        //   padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        // ),
        child: Container(
          child: SvgIcon(
            name: icon ?? 'ic_follow',
            color: isActive ?? false ? kPrimaryColor : Colors.black,
          ),
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}
