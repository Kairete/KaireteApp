import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ErrorPopup {
  ErrorPopup(
      {required this.content,
      this.updateIsShowPopup,
      this.isEnableClickOutside = true});
  final Widget content;
  final Function()? updateIsShowPopup;
  final bool isEnableClickOutside;

  void open() {
    Get.defaultDialog(
        title: '',
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        titleStyle: TextStyle(height: 0),
        backgroundColor: Colors.transparent,
        onWillPop: () {
          updateIsShowPopup!();
          return Future.value(isEnableClickOutside);
        },
        content: content);
  }
}
