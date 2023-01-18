import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/register/controllers/register_controller.dart';

import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';

class RegisterScreen extends GetView {
  RegisterScreen({Key? key}) : super(key: key);

  RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: Obx(() => Column(
                  children: [
                    Text(
                      'Register',
                      style: kTextMediumtStyle.copyWith(fontSize: 30),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    KaireteTextField(
                      onChanged: (value) {
                        controller.errorName.value = '';
                      },
                      hint: 'User name',
                      controller: controller.nameController,
                      errorText: controller.errorName.value,
                    ),
                    KaireteTextField(
                      onChanged: (value) {
                        controller.errorEmail.value = '';
                      },
                      hint: 'Email',
                      controller: controller.emailController,
                      errorText: controller.errorEmail.value,
                    ),
                    KairetePassWordTextField(
                      onChanged: (value) {
                        controller.errorPass.value = '';
                      },
                      hint: 'Password',
                      controller: controller.passController,
                      errorText: controller.errorPass.value,
                    ),
                    KaireteTextField(
                      onChanged: (value) {
                        controller.errorDob.value = '';
                      },
                      onTap: () {
                        controller.toDatePicker();
                      },
                      hint: 'Date of birth',
                      controller: controller.dobController,
                      readOnly: true,
                      errorText: controller.errorDob.value,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    KairetePrimaryButton(
                      onTap: () {
                        controller.onRegister();
                      },
                      title: 'Register',
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        KaireteTextButton(
                          onTap: () {
                            controller.toLogin();
                          },
                          style: kTextMediumtStyle.copyWith(fontSize: 16),
                          color: kIconSubduedColor,
                          title: 'Login?',
                          width: 200,
                        )
                      ],
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
