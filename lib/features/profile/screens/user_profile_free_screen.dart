import 'package:flutter/material.dart';
import 'package:kairete/features/profile/controllers/user_profile_feed_controller.dart';

import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/user.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';
import 'package:get/get.dart';

class UserProfileFeedScreen extends StatelessWidget {
  UserProfileFeedScreen({Key? key}) : super(key: key);

  UserProfileFeedController controller = Get.put(UserProfileFeedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Profile post',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Column(
                children: [
                  if (index == 0)
                    GestureDetector(
                      onTap: () {
                        controller.toCreate();
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16, top: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                          color: kF7FBFE,
                        ),
                        child: Text(
                          'Write something…',
                          style: kTextRegularStyle.copyWith(
                            color: Colors.black.withAlpha(60),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  NewfeedCell(
                    onTapDetail: () {
                      controller.toDetail(item: item);
                    },
                    onTapAvatar: () {
                      controller.toProfile(user: item.user);
                    },
                    onTapHeader: () {
                      if (item.type == ContentTypeNewFeed.blogEntry) {
                        controller.toMyBlogs(blog: item.blogEntryItem);
                      }
                    },
                    authorBlog: item.type == ContentTypeNewFeed.blogEntry
                        ? item.blogEntryItem?.user?.username
                        : null,
                    onTapReply: () {
                      controller.toReplies(item: item);
                    },
                    onTapReactions: () {
                      controller.showReactionPopup(item: item);
                    },
                    avatar: item.user?.avatarUrls?.l,
                    nameImage: (item.user?.customFields?.fullName ??
                        item.user?.username ??
                        ''),
                    userName: item.user?.customFields?.fullName ??
                        item.user?.username ??
                        '',
                    blogTitle: item.blogEntryItem?.blog?.title,
                    groupTitle: item.groupPostItem?.group?.name,
                    date: item.itemDate,
                    commentCount: item.commentCount,
                    shareCount: item.shareCount,
                    reactionIconUrl: item.reactionIconUrl,
                    isShowLike:
                        item.user?.userId != UserManager.instance.userId,
                    reactions: item.reactions,
                    messagePlainText: item.messagePlainText,
                    title: (item.title != '' &&
                            item.groupPostItem == null &&
                            item.type != ContentTypeNewFeed.tlGroupPost)
                        ? item.title
                        : null,
                    thumbnailUrl:
                        item.blogEntryItem?.attachments?[0].thumbnailUrl ??
                            item.groupPostItem?.firstComment?.attachments?[0]
                                .thumbnailUrl,
                  ),
                ],
              );
            },
          )),
    );
  }
}
