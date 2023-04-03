import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';

import '../../../components/cache_image.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/user.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

// ignore: must_be_immutable
class ForumDetailScreen extends StatelessWidget {
  ForumDetailScreen({Key? key}) : super(key: key);

  ForumDetailController controller = Get.put(ForumDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          controller.item?.title ?? '',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          margin: const EdgeInsets.only(top: 16),
          child: Obx(() => controller.items.isEmpty
              ? Container()
              : ListView.builder(
                  itemCount: controller.items.length + 1,
                  itemBuilder: (context, index) {
                    final originIndex = index == 0 ? 0 : index - 1;
                    final item = controller.items[originIndex];
                    return index == 0
                        ? GestureDetector(
                            onTap: () {
                              controller.toCreate();
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 24, 16, 24),
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 16),
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
                              ],
                            ),
                          )
                        : Container(
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: kBorderDefaultColor,
                                    ),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      KaireteCacheNetworkImage(
                                          url: item.user?.avatarUrls?.l ?? '',
                                          width: 36,
                                          height: 36,
                                          isCircle: true,
                                          nameImage: (item.user?.customFields
                                                  ?.fullName ??
                                              item.user?.username ??
                                              '')),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title ?? '',
                                              style: kTextTitle.copyWith(
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              item.username ?? '',
                                              style: kTextTitle.copyWith(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.message ?? '',
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                        style: kTextMediumtStyle.copyWith(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      if (item.reactions != null)
                                        ReactionsItemView(
                                            reactions: item.reactions ?? [])
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey.shade400,
                                    ),
                                    color: kF5F5F5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      KaireteIconButton(
                                        title: '${item.replyCount ?? 0}',
                                        onTap: () {
                                          controller.toComment(item: item);
                                        },
                                      ),
                                      KaireteIconButton(
                                        title: 'Like',
                                        icon: 'ic_like',
                                        onTap: () {
                                          controller.showReactionPopup(
                                              item: item);
                                        },
                                        url: item.isReation
                                            ? item.reactionIconUrl
                                            : null,
                                      ),
                                      KaireteIconButton(
                                        title: '${item.viewCount ?? 0}',
                                        icon: 'ic_view_eye',
                                        width: 10,
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                              ],
                            ),
                          );
                  },
                )),
        ),
      ),
    );
  }
}
