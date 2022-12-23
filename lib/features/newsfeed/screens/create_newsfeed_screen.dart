import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_form.dart';
import 'package:kairete/features/newsfeed/controllers/create_newsfeed_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';

// ignore: must_be_immutable
class CreateNewsfeedScreen extends StatelessWidget {
  CreateNewsfeedScreen({Key? key}) : super(key: key);

  CreateNewsfeedController controller = Get.put(CreateNewsfeedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Create newsfeed',
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
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaireteTextField(
                onChanged: (value) {
                  controller.textOnChanged(text: value);
                },
                hint: 'Write something…',
                maxLine: 10,
                borderColor: kPrimaryColor,
                controller: controller.textController,
              ),
              InkWell(
                onTap: () {
                  controller.onSelectedImage();
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      width: 1,
                      color: kPrimaryColor,
                    ),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: kPrimaryColor,
                      size: 50,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.paths
                            .map((element) => ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(element),
                                    width: (1.sw - 48) / 3,
                                    height: (1.sw - 48) / 3,
                                    fit: BoxFit.fill,
                                  ),
                                ))
                            .toList(),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
