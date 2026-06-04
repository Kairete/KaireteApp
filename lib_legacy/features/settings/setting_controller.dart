import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_form.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/profile/usecase/user_profile_usecase.dart';
import 'package:kairete/features/settings/activity/activity_controller.dart';
import 'package:kairete/features/settings/activity/activiy_screen.dart';
import 'package:kairete/features/settings/setting_model.dart';
import 'package:kairete/features/settings/setting_usecase.dart';
import 'package:kairete/features/settings/tearm/tearm_policy_screen.dart';
import 'package:kairete/helper/notification_service.dart';
import 'package:kairete/local/data_local.dart';

import '../../helper/user.dart';

class SettingController extends GetxController {
  var settings = <SettingModel>[].obs;
  SettingUsecase usecase = ISettingUsecase();
  UserProfileUsecase profileUsecase = IUserProfileUsecase();
  var user = User().obs;

  String? userName;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? newPass;

  @override
  void onInit() {
    super.onInit();
    fetchMe();
    settings.addAll([
      SettingModel(icon: Icons.person, title: 'Full name'),
      SettingModel(icon: Icons.edit, title: 'Username'),
      SettingModel(icon: Icons.email, title: 'Email'),
      SettingModel(icon: Icons.person_add, title: 'Following people'),
      SettingModel(icon: Icons.person_remove, title: 'Follower people'),
      SettingModel(icon: Icons.visibility, title: 'Bookmarks threads'),
      SettingModel(icon: Icons.language, title: 'Language'),
      SettingModel(icon: Icons.password, title: 'Password'),
      SettingModel(icon: Icons.brightness_6, title: 'Dark Mode'),
      SettingModel(icon: Icons.rule, title: 'Terms and rules'),
      SettingModel(icon: Icons.privacy_tip, title: 'Privacy policy'),
    ]);
  }

  void fetchMe() async {
    final json = await profileUsecase.fetchData();
    user.value = User.fromJson(json['me']);
  }

  void onItemClick(int index) {
    switch (index) {
      case 0:
        Get.bottomSheet(
          SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: KaireteTextField(
                    onChanged: (text) {
                      firstName = text;
                    },
                    hint: 'input first name',
                    // text: user.value.username,
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: KaireteTextField(
                    onChanged: (text) {
                      lastName = text;
                    },
                    hint: 'input last name',
                  ),
                ),
                KairetePrimaryButton(
                  onTap: () async {
                    final body = {
                      'first_name': firstName,
                      'last_name': lastName,
                    };
                    final json = await usecase.updateFullName(body: body);
                    if (json != null) {
                      showKairetePopup(
                          onTapDone: () {
                            Get.back();
                            fetchMe();
                          },
                          title: 'Update successfuly');
                    }
                  },
                  title: 'Done',
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          )),
        );
        break;
      case 1:
        Get.bottomSheet(
          SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: KaireteTextField(
                    onChanged: (text) {
                      userName = text;
                    },
                    hint: 'input username',
                    text: user.value.username,
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: KairetePassWordTextField(
                    onChanged: (text) {
                      password = text;
                    },
                    hint: 'input password',
                  ),
                ),
                KairetePrimaryButton(
                  onTap: () async {
                    final body = {
                      'username': userName,
                      'current_password': password,
                    };
                    final json = await usecase.updateUserName(body: body);
                    if (json != null) {
                      showKairetePopup(
                          onTapDone: () {
                            Get.back();
                            fetchMe();
                          },
                          title: 'Update successfuly');
                    }
                  },
                  title: 'Done',
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          )),
        );
        break;
      case 2:
        Get.bottomSheet(
          SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: KaireteTextField(
                    onChanged: (text) {
                      email = text;
                    },
                    hint: 'input email',
                    text: user.value.email,
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: KairetePassWordTextField(
                    onChanged: (text) {
                      password = text;
                    },
                    hint: 'input password',
                  ),
                ),
                KairetePrimaryButton(
                  onTap: () async {
                    final body = {
                      'email': email,
                      'current_password': password,
                    };
                    print(body);
                    final json = await usecase.updateEmail(body: body);
                    if (json != null) {
                      showKairetePopup(
                          onTapDone: () {
                            Get.back();
                            fetchMe();
                          },
                          title: 'Update successfuly');
                    }
                  },
                  title: 'Done',
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          )),
        );
        break;
      case 3:
        Get.to(() => ActivityScreen(), arguments: {
          'type': ActivityType.following,
        });
        break;
      case 4:
        Get.to(() => ActivityScreen(), arguments: {
          'type': ActivityType.follower,
        });
        break;
      case 5:
        // Get.to(() => ActivityScreen(), arguments: {
        //   'type': ActivityType.bookmark,
        // });
        showKairetePopup(onTapDone: () {}, content: 'Updating');

        break;
      case 6:
        showKairetePopup(onTapDone: () {}, content: 'Updating');
        break;
      case 7:
        Get.bottomSheet(
          SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: KairetePassWordTextField(
                    onChanged: (text) {
                      password = text;
                    },
                    hint: 'input current password',
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: KairetePassWordTextField(
                    onChanged: (text) {
                      newPass = text;
                    },
                    hint: 'input new password',
                  ),
                ),
                KairetePrimaryButton(
                  onTap: () async {
                    final body = {
                      'new_password': newPass,
                      'current_password': password,
                    };
                    print(body);
                    final json = await usecase.updatePass(body: body);
                    if (json != null) {
                      showKairetePopup(
                          onTapDone: () {
                            Get.back();
                            fetchMe();
                          },
                          title: 'Update successfuly');
                    }
                  },
                  title: 'Done',
                ),
                SizedBox(
                  height: 24,
                )
              ],
            ),
          )),
        );
        break;
      case 8:
        showKairetePopup(onTapDone: () {}, content: 'Updating');
        break;
      case 9:
        Get.to(() => TermsAndPolicyScreen(), arguments: {
          'type': 'tearm',
        });
        break;
      case 10:
        Get.to(() => TermsAndPolicyScreen(), arguments: {
          'type': 'policy',
        });
        break;
      default:
        print('Unknown item clicked');
    }
  }

  void onLogout() async {
    // NotificationManager.instance.disableNotice();
    // await LocalManager.instance.remove(key: PreferencesKey.token);
    // UserManager.instance.userId = null;
    // Get.offAllNamed(Routes.login);
    print("=====a");
    await NotificationManager.instance.deleteFCM();
    print("=====b");

    await LocalManager.instance.remove(key: PreferencesKey.token);
    UserManager.instance.userId = null;
    Get.offAllNamed(Routes.login);
  }
}
