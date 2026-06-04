import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hashtagable/widgets/hashtag_text_field.dart';
import 'package:kairete/features/blogs/controllers/blog_create_controller.dart';

import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';

// ignore: must_be_immutable
class BlogCreateScreen extends StatelessWidget {
  BlogCreateScreen({super.key});

  BlogCreateController controller = Get.put(BlogCreateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Create blog',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
        actions: [
          Obx(() => KairetePrimaryButton(
                onTap: () {
                  controller.createBlog();
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
                Obx(() => dropdownButton(
                    title: 'Your blogs:',
                    content: controller.selectedBlog.value.title ??
                        'Post blog entry in',
                    onTap: () {
                      controller.showBlogs();
                    })),
                SizedBox(
                  height: 8,
                ),
                Obx(() => dropdownButton(
                    title: 'UBS Category:',
                    content: controller.selectedCategory.value.title ??
                        'Post blog entry in...',
                    onTap: () {
                      controller.showCategory();
                    })),
                SizedBox(
                  height: 16,
                ),
                KaireteTextField(
                  onChanged: (value) {
                    controller.checkData();
                  },
                  hint: 'Title',
                  maxLine: 1,
                  borderColor: kPrimaryColor,
                  controller: controller.titleController,
                ),
                KaireteTextField(
                  onChanged: (value) {
                    controller.checkData();
                  },
                  hint: 'Write something…',
                  maxLine: 10,
                  borderColor: kPrimaryColor,
                  controller: controller.messageController,
                  textStyle: kTextRegularStyle.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
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
                    controller.tags = value;
                  },
                ),
                // Spacer(),
                SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: kPrimaryColor),
                      borderRadius: BorderRadius.circular(8),
                      color: kPrimaryColor,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'post a new entry',
                      style: kTextRegularStyle.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
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
