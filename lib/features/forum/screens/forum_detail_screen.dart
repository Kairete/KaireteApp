import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';

import '../../../components/cache_image.dart';
import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
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
          child: Obx(() => ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: kBorderDefaultColor,
                            ),
                            color: Colors.grey.shade200,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KaireteCacheNetworkImage(
                                  url: item.user?.avatarUrls?.l ?? '',
                                  width: 36,
                                  height: 36,
                                  isCircle: true,
                                  nameImage:
                                      (item.user?.customFields?.fullName ??
                                          item.user?.username ??
                                          '')),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title ?? '',
                                      style: kTextTitle.copyWith(fontSize: 16),
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

                        // Padding(
                        //   padding: const EdgeInsets.only(left: 16, right: 16),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       if (item.title != '' &&
                        //           item.groupPostItem == null)
                        //         Text(
                        //           item.title ?? '',
                        //           style: kTextMediumtStyle.copyWith(
                        //               color: Colors.black,
                        //               fontSize: 22,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //       if (item.title != '' &&
                        //           item.groupPostItem == null)
                        //         const SizedBox(
                        //           height: 16,
                        //         ),
                        //       if (item.blogEntryItem?.attachments != null ||
                        //           item.groupPostItem?.firstComment
                        //                   ?.attachments !=
                        //               null)
                        //         KaireteCacheNetworkImage(
                        //           url: item.blogEntryItem?.attachments?[0]
                        //                   .thumbnailUrl ??
                        //               item.groupPostItem?.firstComment
                        //                   ?.attachments?[0].thumbnailUrl ??
                        //               '',
                        //         ),
                        //       if (item.blogEntryItem?.attachments != null ||
                        //           item.groupPostItem?.firstComment
                        //                   ?.attachments !=
                        //               null)
                        //         const SizedBox(
                        //           height: 16,
                        //         ),
                        //       Text(
                        //         item.messagePlainText ?? '',
                        //         maxLines: 5,
                        //         overflow: TextOverflow.ellipsis,
                        //         style: kTextMediumtStyle.copyWith(
                        //             color: Colors.black,
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.w400),
                        //       ),
                        //       const SizedBox(
                        //         height: 8,
                        //       ),
                        //       KaireteTextButton(
                        //         onTap: () {
                        //           if (onTapDetail != null) {
                        //             onTapDetail!(item);
                        //           }
                        //         },
                        //         title: 'See detail',
                        //       ),
                        //       if (item.reactions != null)
                        //         ReactionsItemView(
                        //             reactions: item.reactions ?? [])
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: Colors.grey.shade400,
                            ),
                            color: kF5F5F5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              KaireteIconButton(
                                title: '${item.replyCount ?? 0} Replies',
                              ),
                              // if (item.user?.userId !=
                              //     LocalManager.instance
                              //         .read(key: PreferencesKey.token))
                              //   const KaireteIconButton(
                              //     title: 'Like',
                              //     icon: 'ic_like',
                              //   ),
                              KaireteIconButton(
                                title: '${item.viewCount ?? 0}',
                                icon: 'ic_share',
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
