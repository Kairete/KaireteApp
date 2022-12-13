import 'package:flutter/material.dart';

import 'color_constant.dart';

const kMyFont = 'BeVietnamPro';

const kTextHeadingStyle = TextStyle(
    fontFamily: kMyFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: kTextDefaultColor);

const kTextRegularStyle = TextStyle(
    fontFamily: kMyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: kTextDefaultColor);

const kTextMediumtStyle = TextStyle(
    fontFamily: kMyFont,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: kTextMediumColor);

const kTextDisableStyle = TextStyle(
    fontFamily: kMyFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: kTextDisabledColor);

const kTextCriticalStyle = TextStyle(
    fontFamily: kMyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: kTextCriticalColor);

const kTextButtonStyle = TextStyle(
    fontFamily: kMyFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white);

final kGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color(0xFFFA7A7A),
        const Color(0xFF0186D7).withOpacity(0.9),
        const Color(0xFF0087CE).withOpacity(0.75),
        const Color(0xFF72DDFF).withOpacity(0.14),
      ],
      begin: const FractionalOffset(-0.09, 0.1),
      end: const FractionalOffset(0.9, 2.2),
      tileMode: TileMode.clamp,
    ),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(24),
      bottomRight: Radius.circular(24),
    ));
