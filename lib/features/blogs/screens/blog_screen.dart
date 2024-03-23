import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';
import 'package:kairete/features/blogs/screens/blog_create_screen.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<BlogController>(
      init: BlogController(),
      builder: (controller) {
        return Column(
          children: [
            SizedBox(
              height: 8,
            ),
            InkWell(
              onTap: () {
                Get.to(() => BlogCreateScreen(), fullscreenDialog: true);
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                width: double.infinity,
                margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  controller.fetchItems();
                },
                child: ListView.builder(
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
                      onTapWatch: () {
                        controller.toUpdateWatch(item: item);
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
                      isWatched: item.isWatched,
                      // isShowShare: false,
                      commentCount: item.commentCount,
                      isShowLike: item.canReact ?? true,
                      onTapReactions: () {
                        controller.showReactions(blogId: item.blogEntryId ?? 0);
                      },
                      onTapReply: () {
                        controller.toComment(item: item);
                      },
                      onTapHeader: () {
                        controller.toMyBlogs(blog: item);
                      },
                      isFollow: item.user?.isFollowed,
                      isIgnore: item.user?.isIgnored,
                      tags: item.tags,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
