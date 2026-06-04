import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hashtagable/widgets/hashtag_text_field.dart';
import 'package:kairete/features/media/controllers/media_create_controller.dart';

import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';

// ignore: must_be_immutable
class MediaCreateScreen extends StatelessWidget {
  MediaCreateScreen({super.key});

  MediaCreateController controller = Get.put(MediaCreateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Create Media',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
        actions: [
          KairetePrimaryButton(
            onTap: () {
              controller.onCreate();
              // controller.createBlog();
            },
            title: 'POST',
            width: 100,
            // state: controller.isEnable.value
            //     ? StateButton.active
            //     : StateButton.disable,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => dropdownButton(
                    title: 'Your albums:',
                    content: controller.selectedAlbum.value.title ??
                        'Selected album',
                    onTap: () {
                      controller.showAlbums();
                    })),
                SizedBox(
                  height: 8,
                ),
                Obx(() => dropdownButton(
                    title: 'Your categories',
                    content: controller.selectedCategory.value.title ??
                        'Selected category',
                    onTap: () {
                      controller.showCategory();
                    })),
                SizedBox(
                  height: 16,
                ),
                Obx(
                  () => !controller.isSelectedItem.value
                      ? Column(
                          children: [
                            KaireteTextField(
                              onChanged: (value) {
                                controller.checkData();
                              },
                              hint: 'Embed media',
                              maxLine: 1,
                              borderColor: kPrimaryColor,
                              controller: controller.embedEditingController,
                            ),
                            // KaireteTextField(
                            //   onChanged: (value) {
                            //     controller.checkData();
                            //   },
                            //   hint: 'Write something…',
                            //   maxLine: 10,
                            //   borderColor: kPrimaryColor,
                            //   controller: controller.messageController,
                            //   textStyle: kTextRegularStyle.copyWith(
                            //     fontWeight: FontWeight.w300,
                            //     fontSize: 18,
                            //   ),
                            // ),
                          ],
                        )
                      : SizedBox(),
                ),

                HashTagTextField(
                  decoratedStyle: TextStyle(fontSize: 14, color: kPrimaryColor),
                  basicStyle: TextStyle(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: kPrimaryColor),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    hintText: 'Input tag start with #',
                  ),
                  cursorColor: kPrimaryColor,
                  onChanged: (value) {
                    print(value);
                    controller.tags = value;
                  },
                ),
                // Spacer(),
                SizedBox(
                  height: 16,
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
                Obx(
                  () => controller.paths.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              File(controller.paths.value.first),
                              width: (1.sw - 48) / 3,
                              height: (1.sw - 48) / 3,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      : SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column dropdownButton({
    String? title,
    String? content,
    Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? '',
          style: kTextRegularStyle.copyWith(),
        ),
        SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1,
                color: kPrimaryColor,
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    content ?? '',
                    style: kTextRegularStyle,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: kPrimaryColor,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
