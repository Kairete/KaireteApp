import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/profile/controllers/use_profile_controller.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  UserProfileController controller = Get.put(UserProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: kTextTitle.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KaireteCacheNetworkImage(
                  url: controller.user.value.avatarUrls?.m ?? '',
                  nameImage: controller.user.value.username,
                  width: 80,
                  height: 80,
                  fontSize: 40,
                ),
                SizedBox(
                  height: 60,
                ),
                InfoProfileItem(
                  title: 'Username:',
                  content: controller.user.value.username,
                ),
                SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Messages:',
                  content: (controller.user.value.messageCount ?? 0).toString(),
                ),
                SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Reaction score:',
                  content:
                      (controller.user.value.reactionScore ?? 0).toString(),
                ),
                SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Trophy points:',
                  content: (controller.user.value.trophyPoints ?? 0).toString(),
                ),
                SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Email:',
                  content: controller.user.value.email,
                ),
                SizedBox(
                  height: 16,
                ),
                Expanded(child: Container()),
                KairetePrimaryButton(
                  onTap: () {
                    print('aa');
                    controller.onLogout();
                  },
                  title: 'Log out',
                )
              ],
            )),
      ),
    );
  }
}

class InfoProfileItem extends StatelessWidget {
  const InfoProfileItem({
    Key? key,
    this.title,
    this.content,
  }) : super(key: key);

  final String? title;
  final String? content;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title ?? 'Username:',
          style: kTextRegularStyle,
        ),
        SizedBox(
          width: 8,
        ),
        Flexible(
          child: Text(
            content ?? '',
            textAlign: TextAlign.right,
            style: kTextMediumtStyle,
          ),
        )
      ],
    );
  }
}
