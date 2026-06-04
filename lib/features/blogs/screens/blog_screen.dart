import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';
import 'package:kairete/features/blogs/screens/blog_create_screen.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';
import 'package:kairete/widgets/cards/kairete_blog_card.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  int _likeCount(dynamic item) {
    if (item.reactionScore != null && item.reactionScore! > 0) {
      return item.reactionScore!;
    }
    return item.reactions?.length ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<BlogController>(
        init: BlogController(),
        builder: (controller) {
          return Column(
            children: [
              const SizedBox(height: 8),
              KaireteTextFieldButotn(
                onTap: () {
                  Get.to(() => BlogCreateScreen(), fullscreenDialog: true);
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    controller.fetchItems(isRefresh: true);
                  },
                  child: ListView.builder(
                    itemCount: controller.items.length,
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      return KaireteBlogCard(
                        authorName: item.user?.username ?? '',
                        title: item.title ?? '',
                        blogName: item.blog?.title,
                        preview: item.messagePlainText,
                        avatarUrl: item.user?.avatarUrls?.l,
                        thumbnailUrl: item.coverImage?.thumbnailUrl,
                        dateTimestamp: item.attachments?.isNotEmpty == true
                            ? item.attachments![0].attachDate
                            : null,
                        commentCount: item.commentCount ?? 0,
                        likeCount: _likeCount(item),
                        onTapDetail: () => controller.toDetail(item: item),
                        onTapAvatar: () {
                          Get.to(
                            () => UserProfileScreen(),
                            arguments: {'id': item.user?.userId},
                          );
                        },
                        onTapBlogName: () => controller.toMyBlogs(blog: item),
                        onTapLike: () {
                          controller.showReactions(
                            blogId: item.blogEntryId ?? 0,
                          );
                        },
                        onTapReply: () => controller.toComment(item: item),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
