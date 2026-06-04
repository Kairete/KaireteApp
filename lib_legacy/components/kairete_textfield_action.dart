import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/dashboard/controllers/dashboard_controller.dart';

class KaireteTextFieldButotn extends StatelessWidget {
  const KaireteTextFieldButotn({super.key, this.onTap});

  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        width: double.infinity,
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
          color: kF7FBFE,
        ),
        child: Text(
          'Write something…',
          style: kTextRegularStyle.copyWith(
            color: Colors.black.withAlpha(60),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class KaireteWriteTextField extends StatelessWidget {
  KaireteWriteTextField({
    super.key,
    this.onTap,
    this.onChanged,
    this.onSend,
    this.controller,
  });

  final Function()? onTap;
  final Function(String)? onChanged;
  final Function(String?)? onSend;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 8, 0, kBottomSafea),
        width: double.infinity,
        height: 120,
        child: Column(
          children: [
            Divider(),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 16,
                left: 16,
              ),
              child: Row(
                children: [
                  KaireteCacheNetworkImage(
                    url: Get.find<DashboardController>()
                            .user
                            .value
                            .avatarUrls
                            ?.o ??
                        '',
                    nameImage:
                        Get.find<DashboardController>().user.value.username,
                    width: 30,
                    height: 30,
                    isCircle: true,
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: onTap != null
                        ? Text(
                            'Write something…',
                            style: kTextRegularStyle.copyWith(
                              color: Colors.black.withAlpha(100),
                              fontSize: 16,
                            ),
                          )
                        : TextField(
                            decoration: InputDecoration.collapsed(
                              hintText: 'Write something…',
                            ),
                            onChanged: onChanged,
                            controller: controller,
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send,
                      color: kPrimaryColor,
                    ),
                    onPressed: () {
                      if (onSend != null) {
                        onSend!(controller?.text);
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
