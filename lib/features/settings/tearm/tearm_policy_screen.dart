import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/features/settings/tearm/tearm_policy_controller.dart';

class TermsAndPolicyScreen extends StatelessWidget {
  final TermsAndPolicyController controller =
      Get.put(TermsAndPolicyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Policy'),
        backgroundColor: kPrimaryColor,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: HtmlWidget(
            controller.htmlData.value,
            // Add any customization options here
          ),
        );
      }),
    );
  }
}
