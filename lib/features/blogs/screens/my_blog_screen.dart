import 'package:flutter/material.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:get/get.dart';

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
                        controller.showReactions(blogId: item.blogEntryId ?? 0);
                      },
                      onTapReply: () {
                        controller.toComment(item: item);
                      },
                      isWatched: item.isWatched,
                      onTapWatch: () {
                        controller.toUpdateWatch(item: item);
                      },
                      isFollow: item.user?.isFollowed,
                      isIgnore: item.user?.isIgnored,
                    );
                  },
                ),
              );
            },
          ),
        ));
  }
}
