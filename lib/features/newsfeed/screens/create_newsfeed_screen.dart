import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_form.dart';
import 'package:kairete/features/newsfeed/controllers/create_newsfeed_controller.dart';
import 'package:get/get.dart';

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
        child: Column(
          children: [
            KaireteTextField(
              onChanged: (value) {
                controller.textOnChanged(text: value);
              },
              hint: 'Write something…',
              maxLine: 10,
              borderColor: kPrimaryColor,
              controller: controller.textController,
            )
          ],
        ),
      ),
    );
  }
}
