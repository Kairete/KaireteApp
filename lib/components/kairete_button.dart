import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
  }) : super(key: key);

  final double? height;
  final double? width;
  final String? title;
  final Color? backgroundColor;
  final Color? titleColor;
  final Function onTap;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        height: height ?? 48,
        width: width,
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
