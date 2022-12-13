import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_form.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/login/controllers/login_controller.dart';
import '../../../constants/color_constant.dart';

class LoginScreen extends GetView {
  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Obx(() => Column(
                children: [
                  Text(
                    'Login',
                    style: kTextMediumtStyle.copyWith(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  KaireteTextField(
                    onChanged: (value) {
                      controller.errorName.value = '';
                    },
                    hint: 'Your name or email address',
                    controller: controller.nameController,
                    errorText: controller.errorName.value,
                  ),
                  KairetePassWordTextField(
                    onChanged: (value) {
                      controller.errorPass.value = '';
                    },
                    hint: 'Password',
                    controller: controller.passController,
                    errorText: controller.errorPass.value,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  KairetePrimaryButton(
                    onTap: () {
                      controller.onLogin();
                    },
                    title: 'Login',
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      KaireteTextButton(
                        onTap: () {
                          controller.toRegister();
                        },
                        style: kTextMediumtStyle.copyWith(fontSize: 16),
                        color: kIconSubduedColor,
                        title: 'Register?',
                        width: 200,
                      )
                    ],
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
