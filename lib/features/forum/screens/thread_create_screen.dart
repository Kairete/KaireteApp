import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_form.dart';
import 'package:kairete/features/newsfeed/controllers/create_newsfeed_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../controllers/thread_create_controller.dart';

// ignore: must_be_immutable
class ThredCreateScreen extends StatelessWidget {
  ThredCreateScreen({Key? key}) : super(key: key);

  ThredCreateController controller = Get.put(ThredCreateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Create thread',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
        actions: [
          Obx(() => KairetePrimaryButton(
                onTap: () {
                  controller.onCreate();
                },
                title: 'POST',
                width: 100,
                state: controller.isEnable.value
                    ? StateButton.active
                    : StateButton.disable,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KaireteTextField(
                  onChanged: (value) {
                    controller.textOnChanged();
                  },
                  hint: 'Enter title',
                  controller: controller.titleController,
                ),
                KaireteTextField(
                  onChanged: (value) {
                    controller.textOnChanged();
                  },
                  hint: 'Write something…',
                  maxLine: 10,
                  borderColor: kPrimaryColor,
                  controller: controller.textController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
