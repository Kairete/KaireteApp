import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<BlogController>(
      init: BlogController(),
      builder: (controller) {
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return NewfeedCell(
              onTapDetail: () {
                controller.toDetail(item: item);
              },
              onTapAvatar: () {
                Get.to(
                  () => UserProfileScreen(),
                  arguments: {'id': item.user?.userId},
                );
              },
              titleCate: item.category?.title,
              userName: item.user?.customFields?.fullName ??
                  item.user?.username ??
                  '',
              title: item.title,
              avatar: item.user?.avatarUrls?.l,
              date: item.attachments?[0].attachDate,
              blogTitle: item.blog?.title,
              thumbnailUrl: item.coverImage?.thumbnailUrl,
              messagePlainText: item.messagePlainText,
              reactionIconUrl: item.reactionIconUrl,
              reactions: item.reactions,
              shareCount: 0,
              // isShowShare: false,
              commentCount: item.commentCount,
              isShowLike: item.canReact ?? true,
              onTapReactions: () {
                controller.showReactions(blogId: item.blogEntryId ?? 0);
              },
              onTapReply: () {
                controller.toComment(item: item);
              },
            );
          },
        );
      },
    );
  }
}
