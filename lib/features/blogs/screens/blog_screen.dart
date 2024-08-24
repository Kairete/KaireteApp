import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';
import 'package:kairete/features/blogs/screens/blog_create_screen.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomSheet: KaireteWriteTextField(
      //   onTap: () {
      // Get.to(() => BlogCreateScreen(), fullscreenDialog: true);
      //   },
      // ),
      body: GetX<BlogController>(
        init: BlogController(),
        builder: (controller) {
          return Column(
            children: [
              SizedBox(
                height: 8,
              ),
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
                        // titleCate: item.category?.title,
                        userName: item.user?.customFields?.fullName ??
                            item.user?.username ??
                            '',
                        title: item.title,
                        avatar: item.user?.avatarUrls?.l,
                        date: item.attachments?[0].attachDate,
                        blogTitle: item.category?.title,
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
                          controller.showReactions(
                              blogId: item.blogEntryId ?? 0);
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
                        onTapTag: (p0) {
                          final tag = p0?.replaceAll('#', '');
                          List<dynamic> list = item.tagsKey.toList();
                          final key = list.firstWhereOrNull((element) {
                            Map<String, dynamic> data = element;
                            return data['tag'].replaceAll(' ', '') == tag;
                          });
                          controller.toTagDetail(id: key?['tag_url']);
                        },
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
