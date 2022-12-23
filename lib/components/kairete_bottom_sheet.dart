import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../constants/font_constant.dart';
import '../constants/size.dart';

void showKaireteBottomSheet(
    {Widget? child,
    Widget? customContent,
    double? paddingTop,
    Function? onComplete,
    bool isShowCloseButton = true,
    bool useRootNavigator = false,
    BuildContext? context,
    bool isDismissible = true,
    bool enableDrag = true,
    String? title}) {
  showMaterialModalBottomSheet(
    context: context ?? Get.context!,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    bounce: true,
    builder: (context) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            if (title != null)
              Text(
                title,
                style: kTextHeadingStyle.copyWith(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
            customContent ??
                SizedBox(
                  height: 1.sh - (paddingTop ?? kTopSafea + 70),
                  child: child,
                )
          ],
        ),
      );
    },
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(16),
        topLeft: Radius.circular(16),
      ),
    ),
  ).whenComplete(() {
    if (onComplete == null) {
      return;
    }
    onComplete();
  });
}
