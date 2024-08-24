import 'package:flutter/material.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/features/blogs/screens/blog_create_screen.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:get/get.dart';

import '../../../components/kairete_button.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';
import '../controllers/my_blog_controller.dart';

class MyBlogScreen extends StatelessWidget {
  MyBlogScreen({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: baseAppBar(
          key: _key,
          isShowBack: true,
          isShowMenu: false,
          isShowSearch: false,
          title: 'Blogs Detail',
        ),
        body: SafeArea(
          child: GetX<MyBlogController>(
            init: MyBlogController(),
            builder: (controller) {
              return RefreshIndicator(
                onRefresh: () async {
                  controller.fetchItems();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () => ActionButton(
                            padding:
                                EdgeInsets.only(right: 16, bottom: 8, top: 8),
                            title: '',
                            onTap: () {
                              controller.updateWatch();
                            },
                            icon: 'ic_ignore',
                            isActive: controller.isWatchedForum.value,
                          ),
                        ),
                        CreateBlogButton()
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
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
                            commentCount: item.commentCount,
                            isShowLike: item.canReact ?? true,
                            onTapReactions: () {
                              controller.showReactions(
                                  blogId: item.blogEntryId ?? 0);
                            },
                            onTapReply: () {
                              controller.toComment(item: item);
                            },
                            isWatched: item.isWatched,
                            onTapWatch: () {
                              controller.toUpdateWatch(item: item);
                            },
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
                            // isFollow: item.user?.isFollowed,
                            // isIgnore: item.user?.isIgnored,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }
}

class CreateBlogButton extends StatelessWidget {
  CreateBlogButton({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    print('=====');
    return InkWell(
      onTap: () {
        Get.to(() => BlogCreateScreen(), fullscreenDialog: true);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          Icons.add,
          color: color ?? kPrimaryColor,
        ),
      ),
    );
  }
}
