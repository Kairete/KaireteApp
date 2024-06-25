import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/media/controllers/media_type_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';

class MediaTypeScreen extends StatelessWidget {
  MediaTypeScreen({super.key});
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: baseAppBar(
        key: _key,
        isShowBack: true,
        isShowMenu: false,
        isShowSearch: false,
        isShowActions: false,
      ),
      body: GetX<MediaTypeController>(
        init: MediaTypeController(),
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              // controller.fetchItems(isRefresh: true);
            },
            child: ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return NewfeedCell(
                  onTapDetail: () {
                    // controller.toDetail(item: item);
                  },
                  onTapAvatar: () {
                    Get.to(
                      () => UserProfileScreen(),
                      arguments: {'id': item.user?.userId},
                    );
                  },
                  onTapWatch: () {
                    // controller.toUpdateWatch(item: item);
                  },
                  userName: item.user?.username ?? '',
                  title: item.title,
                  avatar: item.user?.avatarUrls?.l,
                  date: item.mediaDate,
                  blogTitle: item.containerName,
                  thumbnailUrl: item.thumbnailUrl,
                  category: item.containerName,
                  // reactionIconUrl: item.reactionIconUrl,
                  reactions: item.reactions,
                  shareCount: 0,
                  // isWatched: item.isWatched,
                  // isShowShare: false,
                  commentCount: item.commentCount,
                  isShowLike: item.canReact ?? true,
                  onTapReactions: () {
                    // controller.showReactions(
                    //     blogId: item.blogEntryId ?? 0);
                  },
                  onTapReply: () {
                    controller.toReplies(newFeedId: item.newfeedId ?? 0);
                    // controller.toComment(item: item);
                  },
                  onTapHeader: () {
                    // controller.toMyBlogs(blog: item);
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
                    // controller.toTagDetail(id: key?['tag_url']);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
