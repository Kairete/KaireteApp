import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/profile/controllers/use_profile_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kairete/features/settings/setting_screen.dart';
import 'package:kairete/helper/extenstions.dart';
import 'package:kairete/helper/time.dart';

import '../../../constants/color_constant.dart';
import '../../../helper/user.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

// ignore: must_be_immutable
class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({Key? key}) : super(key: key);

  UserProfileController controller = Get.put(UserProfileController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Row(
            children: [
              KaireteCacheNetworkImage(
                url: controller.user.value.avatarUrls?.l ?? '',
                width: 35,
                height: 35,
                nameImage: controller.user.value.username,
                isCircle: true,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.user.value.username ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    (controller.user.value.followerCount ?? 0).formatNumber(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          controller.isCurrentUser
              ? IconButton(
                  onPressed: () {
                    Get.to(() => SettingScreen());
                  },
                  icon: Icon(
                    Icons.settings,
                  ),
                )
              : SizedBox()
        ],
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, kBottomSafea),
        child: controller.id == null
            ? KairetePrimaryButton(
                onTap: () {
                  controller.onLogout();
                },
                title: 'Log out',
              )
            : null,
      ),
      body: SafeArea(
        child: Obx(
          () => ListView.builder(
            itemCount: controller.items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return InfoView(controller: controller);
              } else {
                final item = controller.items[index - 1];
                return Column(
                  children: [
                    if (index - 1 == 0)
                      GestureDetector(
                        onTap: () {
                          controller.toCreate();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16, top: 16),
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
                    NewfeedCell(
                      onTapDetail: () {
                        controller.toDetail(item: item);
                      },
                      onTapAvatar: () {
                        controller.toProfile(user: item.user);
                      },
                      onTapHeader: () {
                        if (item.type == ContentTypeNewFeed.blogEntry) {
                          controller.toMyBlogs(blog: item.blogEntryItem);
                        }
                      },
                      authorBlog: item.type == ContentTypeNewFeed.blogEntry
                          ? item.blogEntryItem?.user?.username
                          : null,
                      onTapReply: () {
                        controller.toReplies(item: item);
                      },
                      onTapReactions: () {
                        controller.showReactionPopup(item: item);
                      },
                      avatar: item.user?.avatarUrls?.l,
                      nameImage: (item.user?.customFields?.fullName ??
                          item.user?.username ??
                          ''),
                      userName: item.user?.customFields?.fullName ??
                          item.user?.username ??
                          '',
                      blogTitle: item.blogEntryItem?.user?.username,
                      groupTitle: item.groupPostItem?.group?.name,
                      date: item.itemDate,
                      commentCount: item.commentCount,
                      shareCount: item.shareCount,
                      reactionIconUrl: item.reactionIconUrl,
                      isShowLike:
                          item.user?.userId != UserManager.instance.userId,
                      reactions: item.reactions,
                      messagePlainText: item.messagePlainText,
                      title: (item.title != '' &&
                              item.groupPostItem == null &&
                              item.type != ContentTypeNewFeed.tlGroupPost)
                          ? item.title
                          : null,
                      thumbnailUrl:
                          item.blogEntryItem?.attachments?[0].thumbnailUrl ??
                              item.groupPostItem?.firstComment?.attachments?[0]
                                  .thumbnailUrl,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final UserProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        controller.user.value.profileBannerUrls?.m != null
            ? KaireteCacheNetworkImage(
                url: controller.user.value.profileBannerUrls?.m ?? '',
                height: 1.sw / 2,
              )
            : Container(
                width: double.infinity,
                height: 1.sw / 2,
                color: const Color(0xFFEDF6FD),
              ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 1.sw / 2 - 60, 16, 8),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KaireteCacheNetworkImage(
                  url: controller.user.value.avatarUrls?.o ?? '',
                  nameImage: controller.user.value.username,
                  width: 120,
                  height: 120,
                  fontSize: 40,
                  isCircle: true,
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  controller.user.value.username ?? '',
                  style: kTextMediumtStyle.copyWith(
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                if (!controller.isCurrentUser)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Obx(() => KaireteActionButton(
                              onTap: () {
                                controller.onFollow();
                              },
                              title: (controller.user.value.isFollowed ?? false)
                                  ? 'Unfollow'
                                  : 'Follow',
                            )),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Obx(() => KaireteActionButton(
                              onTap: () {},
                              title: (controller.user.value.isWatched ?? false)
                                  ? 'Unwatch'
                                  : 'Watch',
                            )),
                      )
                    ],
                  ),
                const SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Messages:',
                  content: (controller.user.value.messageCount ?? 0).toString(),
                ),
                const SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Reaction score:',
                  content:
                      (controller.user.value.reactionScore ?? 0).toString(),
                ),
                const SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Trophy points:',
                  content: (controller.user.value.trophyPoints ?? 0).toString(),
                ),
                const SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Email:',
                  content: controller.user.value.email,
                ),
                const SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'User title:',
                  content: controller.user.value.userTitle,
                ),
                const SizedBox(
                  height: 16,
                ),
                InfoProfileItem(
                  title: 'Joined',
                  content: TimeManager.instance.convertFromTimeStamp(
                      timestamp: controller.user.value.registerDate ?? 0,
                      format: 'dd/MM/yyyy'),
                ),
                const SizedBox(
                  height: 16,
                ),
                // InfoProfileItem(
                //   title: 'Profile post',
                //   onTap: () {
                //     controller.toProfilePost();
                //   },
                // ),
                // const SizedBox(
                //   height: 16,
                // ),
                // Expanded(child: Container()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class InfoProfileItem extends StatelessWidget {
  const InfoProfileItem({
    Key? key,
    this.title,
    this.content,
    this.onTap,
  }) : super(key: key);

  final String? title;
  final String? content;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title ?? 'Username:',
            style: kTextRegularStyle,
          ),
          const SizedBox(
            width: 8,
          ),
          Flexible(
            child: (content == '' || content == null)
                ? const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: kPrimaryColor,
                  )
                : Text(
                    content ?? '',
                    textAlign: TextAlign.right,
                    style: kTextMediumtStyle,
                  ),
          )
        ],
      ),
    );
  }
}
