import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/dashboard/controllers/dashboard_controller.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_detail_controller.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import '../../../helper/user.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

// ignore: must_be_immutable
class NewsfeedDetailScreen extends StatelessWidget {
  NewsfeedDetailScreen({Key? key}) : super(key: key);

  NewsfeedDetailController controller = Get.put(NewsfeedDetailController());
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(key: _key, isShowBack: true),
      drawer: AppDrawer(controller: Get.find<DashboardController>()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() => controller.item.value.contentId == null
              ? const SizedBox()
              : NewfeedCell(
                  onTapDetail: () {},
                  onTapAvatar: () {
                    Get.to(
                      () => UserProfileScreen(),
                      arguments: {'id': controller.item.value.user?.userId},
                    );
                  },
                  authorBlog:
                      controller.item.value.type == ContentTypeNewFeed.blogEntry
                          ? controller.item.value.blogEntryItem?.category?.title
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
                  userName:
                      controller.item.value.user?.customFields?.fullName ??
                          controller.item.value.user?.username ??
                          '',
                  blogTitle:
                      controller.item.value.blogEntryItem?.category?.title,
                  // groupTitle: controller.item.value.groupPostItem?.group?.name,
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
