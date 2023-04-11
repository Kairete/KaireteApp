import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/profile/controllers/use_profile_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kairete/helper/time.dart';

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
      bottomSheet: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, kBottomSafea),
        child: controller.id == null
            ? KairetePrimaryButton(
                onTap: () {
                  controller.onLogout();
                },
                title: 'Log out',
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() => Stack(
                children: [
                  controller.user.value.profileBannerUrls?.m != null
                      ? KaireteCacheNetworkImage(
                          url: controller.user.value.profileBannerUrls?.m ?? '',
                          height: 1.sw / 2,
                        )
                      : Container(
                          width: double.infinity,
                          height: 1.sw / 2,
                          color: const Color(0xFFEDF6FD),
                        ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 1.sw / 2 - 60, 16, 8),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          KaireteCacheNetworkImage(
                            url: controller.user.value.avatarUrls?.o ?? '',
                            nameImage: controller.user.value.username,
                            width: 120,
                            height: 120,
                            fontSize: 40,
                            isCircle: true,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          InfoProfileItem(
                            title: 'Username:',
                            content: controller.user.value.username,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          InfoProfileItem(
                            title: 'Messages:',
                            content: (controller.user.value.messageCount ?? 0)
                                .toString(),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          InfoProfileItem(
                            title: 'Reaction score:',
                            content: (controller.user.value.reactionScore ?? 0)
                                .toString(),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          InfoProfileItem(
                            title: 'Trophy points:',
                            content: (controller.user.value.trophyPoints ?? 0)
                                .toString(),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          InfoProfileItem(
                            title: 'Email:',
                            content: controller.user.value.email,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          InfoProfileItem(
                            title: 'User title:',
                            content: controller.user.value.userTitle,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          InfoProfileItem(
                            title: 'Joined',
                            content: TimeManager.instance.convertFromTimeStamp(
                                timestamp:
                                    controller.user.value.registerDate ?? 0,
                                format: 'dd/MM/yyyy'),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          // Expanded(child: Container()),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
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
        const SizedBox(
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
