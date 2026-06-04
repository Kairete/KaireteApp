import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/settings/setting_controller.dart';

class SettingScreen extends StatelessWidget {
  final SettingController controller = Get.put(SettingController());
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
        key: _key,
        isShowBack: true,
        title: 'Account',
        isShowMenu: false,
        isShowSearch: false,
        isShowActions: false,
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, kBottomSafea),
        child: KairetePrimaryButton(
          onTap: () {
            controller.onLogout();
          },
          title: 'Log out',
        ),
      ),
      body: Obx(() {
        return ListView.builder(
          itemCount: controller.settings.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Icon(
                controller.settings[index].icon,
                color: kPrimaryColor,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              title: Text(controller.settings[index].title),
              onTap: () => controller.onItemClick(index),
            );
          },
        );
      }),
    );
  }
}
