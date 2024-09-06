import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/features/media/controllers/media_controller.dart';
import 'package:kairete/features/media/screens/media_create.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';

// ignore: must_be_immutable
class MediaScreen extends StatelessWidget {
  MediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<MediaController>(
        init: MediaController(),
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              // controller.fetchItems(isRefresh: true);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: KaireteActionButton(
                    onTap: () {
                      Get.to(
                        () => MediaCreateScreen(),
                        fullscreenDialog: true,
                      );
                    },
                    width: 100,
                    title: 'Add',
                    height: 30,
                  ),
                ),
                Expanded(
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
                        onTapTitle: () {
                          if (item.mediaType == 'embed') {
                            controller.tolaunchURL(
                                urlString: item.mediaEmbedUrl ?? '');
                          }
                        },
                        onTapThumb: () {
                          if (item.mediaType == 'embed') {
                            controller.tolaunchURL(
                                urlString: item.mediaEmbedUrl ?? '');
                          }
                        },
                        isShowWatch: false,
                        isDetail: false,
                        userName: item.user?.username ?? '',
                        title: item.title,
                        avatar: item.user?.avatarUrls?.l,
                        date: item.mediaDate,
                        // blogTitle: item.containerName,
                        thumbnailUrl: item.thumbnailUrl,
                        category: item.containerName,
                        reactionIconUrl: item.reactionIconUrl,
                        reactions: item.reactions,
                        shareCount: 0,
                        // isWatched: item.isWatched,
                        // isShowShare: false,
                        commentCount: item.commentCount,
                        isShowLike: item.canReact ?? true,
                        onTapReactions: () {
                          controller.showReactionPopup(item: item);
                        },
                        onTapReply: () {
                          controller.toReplies(item: item);
                        },
                        onTapHeader: () {
                          controller.toMediaType(item: item);
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
