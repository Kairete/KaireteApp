import 'package:flutter/material.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_detail_controller.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

// ignore: must_be_immutable
class BlogDetailScreen extends StatelessWidget {
  BlogDetailScreen({Key? key}) : super(key: key);

  BlogsDetailController controller = Get.put(BlogsDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Blogs Detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Obx(() => NewfeedCell(
                onTapDetail: () {},
                titleCate: controller.item.value.category?.title,
                userName: controller.item.value.user?.customFields?.fullName ??
                    controller.item.value.user?.username ??
                    '',
                title: controller.item.value.title,
                avatar: controller.item.value.user?.avatarUrls?.l,
                date: controller.item.value.attachments?[0].attachDate,
                blogTitle: controller.item.value.blog?.title,
                thumbnailUrl: controller.item.value.coverImage?.thumbnailUrl,
                messagePlainText: controller.item.value.messagePlainText,
                reactionIconUrl: controller.item.value.reactionIconUrl,
                reactions: controller.item.value.reactions,
                shareCount: 0,
                commentCount: controller.item.value.commentCount,
                isShowLike: controller.item.value.canReact ?? true,
                onTapReactions: () {
                  controller.showReactions();
                },
                onTapReply: () {
                  controller.toComment();
                },
                isDetail: false,
                onTapAvatar: () {
                  Get.to(
                    () => UserProfileScreen(),
                    arguments: {'id': controller.item.value.user?.userId},
                  );
                },
              )),
        ),
      ),
    );
  }
}
