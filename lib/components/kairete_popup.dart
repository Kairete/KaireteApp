import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/color_constant.dart';
import '../constants/font_constant.dart';
import 'kairete_button.dart';

class KairetePopUpDefault extends StatelessWidget {
  final String? doneTitle;
  final String? cancelTitle;
  final String? title;
  final String? content;
  final Widget? customContent;
  final Widget? icon;
  final Function onTapDone;
  final Function onTapCancel;

  const KairetePopUpDefault(
      {Key? key,
      this.doneTitle,
      this.cancelTitle,
      this.content,
      this.title,
      required this.onTapDone,
      this.customContent,
      this.icon,
      required this.onTapCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: icon == null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon ??
                  Text(
                    title ?? '',
                    style: kTextHeadingStyle.copyWith(fontSize: 20),
                  ),
              const SizedBox(height: 16),
              customContent ??
                  Text(
                    content ?? '',
                    textAlign:
                        icon == null ? TextAlign.start : TextAlign.center,
                    style: kTextRegularStyle.copyWith(color: kTextMediumColor),
                  ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (cancelTitle != null)
                    Expanded(
                      child: KaireteActionButton(
                        backgroundColor: kSurfacePrimarySubdueColor,
                        titleColor: kTextPrimaryColor,
                        onTap: () {
                          Navigator.pop(context);
                          onTapCancel();
                        },
                        title: cancelTitle ?? 'Đồng ý',
                      ),
                    ),
                  if (cancelTitle != null) const SizedBox(width: 8),
                  Expanded(
                    child: KairetePrimaryButton(
                      height: 48,
                      onTap: () {
                        Navigator.pop(context);
                        onTapDone();
                      },
                      title: doneTitle ?? 'Đồng ý',
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

void showKairetePopup(
    {String? cancelTitle,
    String? doneTitle,
    required Function onTapDone,
    Function? onTapCancel,
    bool barrierDismissible = true,
    bool willpopAction = false,
    String? title,
    String? content,
    Widget? customContent,
    Widget? icon}) {
  Get.dialog(
      WillPopScope(
        onWillPop: () {
          if (barrierDismissible) {
            if (willpopAction) {
              onTapDone();
            }
            return Future.value(true);
          }
          return Future.value(false);
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: KairetePopUpDefault(
            cancelTitle: cancelTitle,
            doneTitle: 'Ok',
            title: 'notice',
            content: content,
            customContent: customContent,
            onTapDone: () {
              onTapDone();
            },
            onTapCancel: () {
              if (onTapCancel != null) {
                onTapCancel();
              }
            },
            icon: icon,
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      transitionDuration: const Duration(milliseconds: 300));
}
