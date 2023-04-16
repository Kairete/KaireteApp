import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_detail_controller.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import '../../../helper/user.dart';
import '../../profile/screens/user_profile_screen.dart';

// ignore: must_be_immutable
class NewsfeedDetailScreen extends StatelessWidget {
  NewsfeedDetailScreen({Key? key}) : super(key: key);

  NewsfeedDetailController controller = Get.put(NewsfeedDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Newsfeed detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() => NewfeedCell(
                onTapDetail: () {},
                onTapAvatar: () {
                  Get.to(
                    () => UserProfileScreen(),
                    arguments: {'id': controller.item.value.user?.userId},
                  );
                },
                authorBlog:
                    controller.item.value.type == ContentTypeNewFeed.blogEntry
                        ? controller.item.value.blogEntryItem?.user?.username
                        : null,
                onTapReply: () {
                  controller.toReplies();
                },
                onTapReactions: () {
                  controller.showReactionPopup();
                },
                avatar: controller.item.value.user?.avatarUrls?.l,
                nameImage:
                    (controller.item.value.user?.customFields?.fullName ??
                        controller.item.value.user?.username ??
                        ''),
                userName: controller.item.value.user?.customFields?.fullName ??
                    controller.item.value.user?.username ??
                    '',
                blogTitle: controller.item.value.blogEntryItem?.blog?.title,
                groupTitle: controller.item.value.groupPostItem?.group?.name,
                date: controller.item.value.itemDate,
                commentCount: controller.item.value.commentCount,
                shareCount: controller.item.value.shareCount,
                reactionIconUrl: controller.item.value.reactionIconUrl,
                isShowLike: controller.item.value.user?.userId !=
                    UserManager.instance.userId,
                reactions: controller.item.value.reactions,
                messagePlainText: controller.item.value.messagePlainText,
                title: (controller.item.value.title != '' &&
                        controller.item.value.groupPostItem == null &&
                        controller.item.value.type !=
                            ContentTypeNewFeed.tlGroupPost)
                    ? controller.item.value.title
                    : null,
                thumbnailUrl: controller.item.value.blogEntryItem
                        ?.attachments?[0].thumbnailUrl ??
                    controller.item.value.groupPostItem?.firstComment
                        ?.attachments?[0].thumbnailUrl,
                isDetail: false,
              )),
        ),
      ),
    );
  }
}
