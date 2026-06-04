import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/conversation/create/conversation_create_controller.dart';

import '../../../components/kairete_form.dart';

// ignore: must_be_immutable
class ConversationCreateScreen extends StatelessWidget {
  ConversationCreateScreen({super.key});

  ConversationCreateController controller =
      Get.put(ConversationCreateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Create conversation',
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
                  controller.titleOnChanged(text: value);
                },
                hint: 'Title',
                borderColor: kPrimaryColor,
                controller: controller.titleController,
                textStyle: kTextRegularStyle.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                ),
              ),
              KaireteTextField(
                onChanged: (value) {
                  controller.textOnChanged(text: value);
                },
                hint: 'Message',
                maxLine: 10,
                borderColor: kPrimaryColor,
                controller: controller.textController,
                textStyle: kTextRegularStyle.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
