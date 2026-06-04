import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_form.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/login/controllers/login_controller.dart';
import 'package:kairete/theme/kairete_theme.dart';

class LoginScreen extends GetView {
  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KaireteTheme.bodyBackground,
      appBar: AppBar(
        title: Text(AppConfig.appName),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Accedi',
                      style: kTextMediumtStyle.copyWith(
                        fontSize: 28,
                        color: KaireteTheme.textPrimary,
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Staging: ${AppConfig.apiBaseUrl}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: KaireteTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    KaireteTextField(
                      onChanged: (_) {
                        controller.errorName.value = '';
                        controller.loginError.value = '';
                      },
                      hint: 'Nome utente o email',
                      controller: controller.nameController,
                      errorText: controller.errorName.value,
                    ),
                    KairetePassWordTextField(
                      onChanged: (_) {
                        controller.errorPass.value = '';
                        controller.loginError.value = '';
                      },
                      hint: 'Password',
                      controller: controller.passController,
                      errorText: controller.errorPass.value,
                    ),
                    if (controller.loginError.value.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        controller.loginError.value,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    KairetePrimaryButton(
                      onTap: () => controller.onLogin(),
                      state: controller.isLoading.value
                          ? StateButton.disable
                          : StateButton.active,
                      title: controller.isLoading.value
                          ? 'Accesso in corso...'
                          : 'Accedi',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        KaireteTextButton(
                          onTap: () => controller.toRegister(),
                          style: kTextMediumtStyle.copyWith(fontSize: 16),
                          color: KaireteTheme.textSecondary,
                          title: 'Registrati',
                          width: 200,
                        ),
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
