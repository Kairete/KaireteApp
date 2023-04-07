import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';

import '../../../components/cache_image.dart';
import '../../../helper/time.dart';
import '../../../helper/user.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

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
              titleCate: item.blog?.title,
              userName: item.user?.customFields?.fullName ??
                  item.user?.username ??
                  '',
              avatar: item.user?.avatarUrls?.l,
              date: item.attachments?[0].attachDate,
              blogTitle: item.title,
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
