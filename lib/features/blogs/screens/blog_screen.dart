import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';

import '../../../components/cache_image.dart';
import '../../../helper/time.dart';
import '../../../helper/user.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<BlogController>(
      init: BlogController(),
      builder: (controller) {
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Column(
              children: [
                Container(
                  height: 16,
                  color: kBorderDefaultColor,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                controller.toFilterWithTitle(item: item);
                              },
                              child: Text(
                                item.blog?.title ?? '',
                                style: kTextRegularStyle.copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              item.title ?? '',
                              style: kTextTitle,
                            ),
                            RichText(
                              text: TextSpan(
                                text: item.user?.customFields?.fullName ??
                                    item.user?.username ??
                                    '',
                                style: kTextMediumtStyle.copyWith(
                                  color: Colors.grey,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                                children: [
                                  const TextSpan(
                                      text: ' • ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: TimeManager.instance
                                          .convertFromTimeStamp(
                                              timestamp: item.attachments?[0]
                                                      .attachDate ??
                                                  0),
                                      style: kTextMediumtStyle.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                  const TextSpan(
                                      text: ' • ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  WidgetSpan(
                                    child: InkWell(
                                        onTap: () {
                                          controller.toCate(item: item);
                                        },
                                        child: Text(
                                          item.category?.title ?? '',
                                          style: kTextMediumtStyle.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: kPrimaryColor,
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (item.coverImage != null)
                              KaireteCacheNetworkImage(
                                  url: item.coverImage?.thumbnailUrl ?? ''),
                            if (item.coverImage != null)
                              const SizedBox(
                                height: 16,
                              ),
                            Text(
                              item.messagePlainText ?? '',
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                              style: kTextMediumtStyle.copyWith(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            KaireteTextButton(
                              onTap: () {
                                controller.toDetail(item: item);
                              },
                              title: 'See detail',
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                          ],
                        ),
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
                            // KaireteIconButton(
                            //   title: '${item.commentCount} Replies',
                            //   onTap: () {
                            //     // controller.toReplies(item: item);
                            //   },
                            // ),
                            if (item.user?.userId !=
                                UserManager.instance.userId)
                              KaireteIconButton(
                                title: 'Like',
                                icon: 'ic_like',
                                onTap: () {
                                  controller.showReactions(
                                      blogId: item.blogEntryId ?? 0);
                                },
                                url: item.isReation
                                    ? item.reactionIconUrl
                                    : null,
                                // color: item.isReation ? Colors.blue : null,
                              ),
                            // KaireteIconButton(
                            //   title: '${item.shareCount} Share',
                            //   icon: 'ic_share',
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
