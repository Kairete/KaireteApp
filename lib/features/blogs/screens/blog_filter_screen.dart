import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kairete/features/blogs/controllers/blog_filter_controller.dart';
import 'package:get/get.dart';

import '../../../components/cache_image.dart';
import '../../../components/kairete_button.dart';
import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

// ignore: must_be_immutable
class BlogFilterScreen extends StatelessWidget {
  BlogFilterScreen({Key? key}) : super(key: key);

  BlogFilterController controller = Get.put(BlogFilterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          controller.cate?.title ?? '',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Obx(() => ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return NewfeedCell(
                onTapDetail: () {
                  controller.toDetail(item: item);
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
          )),
    );
  }
}
