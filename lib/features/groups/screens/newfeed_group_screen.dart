import 'package:flutter/material.dart';
import 'package:kairete/features/groups/controllers/newfeed_group_controller.dart';
import 'package:kairete/features/groups/screens/group_screen.dart';
import 'package:get/get.dart';

import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/user.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

class NewfeedGroupScreen extends StatelessWidget {
  NewfeedGroupScreen({Key? key}) : super(key: key);

  NewFeedGroupController controller = Get.put(NewFeedGroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom('Newsfeed'),
      body: SafeArea(
        child: Obx(() => controller.items.isEmpty
            ? const SizedBox()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 16),
                itemCount: controller.items.length + 1,
                itemBuilder: (context, index) {
                  final originIndex = index == 0 ? 0 : index - 1;
                  final item = controller.items[originIndex];
                  return index == 0
                      ? InkWell(
                          onTap: () {
                            controller.toCreate();
                          },
                          child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 24, 16, 24),
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16),
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
                              )),
                        )
                      : NewfeedCell(
                          onTapDetail: () {
                            controller.toDetail(item: item);
                          },
                          onTapAvatar: () {
                            controller.toProfile(user: item.user);
                          },
                          onTapHeader: () {
                            print(item.type);
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
                          thumbnailUrl: item.blogEntryItem?.attachments?[0]
                                  .thumbnailUrl ??
                              item.groupPostItem?.firstComment?.attachments?[0]
                                  .thumbnailUrl,
                        );
                },
              )),
      ),
    );
  }
}
