import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:get/get.dart';
import 'package:kairete/helper/time.dart';

import '../../../components/kairete_button.dart';
import '../../../components/reactions_view.dart';

// ignore: must_be_immutable
class NewsFeedScreen extends StatelessWidget {
  NewsFeedScreen({Key? key}) : super(key: key);

  NewsFeedController controller = Get.put(NewsFeedController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Obx(() => controller.items.isEmpty
          ? const SizedBox()
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
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
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
                      )
                    : Container(
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
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            text: item.user?.customFields
                                                    ?.fullName ??
                                                '',
                                            style: kTextRegularStyle.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                            children: [
                                              if (item.blogEntryItem?.blog
                                                      ?.title !=
                                                  null)
                                                const WidgetSpan(
                                                    child: Icon(
                                                  Icons.play_arrow,
                                                  color: kPrimaryColor,
                                                  size: 16,
                                                )),
                                              TextSpan(
                                                  text: item.blogEntryItem?.blog
                                                          ?.title ??
                                                      '',
                                                  style: kTextRegularStyle
                                                      .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: kPrimaryColor,
                                                    fontSize: 16,
                                                  )),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        RichText(
                                          text: TextSpan(
                                            text: '',
                                            style: kTextMediumtStyle.copyWith(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600),
                                            children: <TextSpan>[
                                              // const TextSpan(
                                              //   text: ' • ',
                                              //   style: TextStyle(
                                              //       fontWeight: FontWeight.bold),
                                              // ),
                                              TextSpan(
                                                  text: TimeManager.instance
                                                      .convertFromTimeStamp(
                                                          timestamp:
                                                              item.itemDate ??
                                                                  0),
                                                  style: kTextMediumtStyle
                                                      .copyWith(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  )),
                                            ],
                                          ),
                                        )
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
                              padding:
                                  const EdgeInsets.only(left: 16, right: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (item.title != '')
                                    Text(
                                      item.title ?? '',
                                      style: kTextMediumtStyle.copyWith(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  if (item.title != '')
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  if (item.blogEntryItem?.attachments != null)
                                    KaireteCacheNetworkImage(
                                        url: item.blogEntryItem?.attachments?[0]
                                                .thumbnailUrl ??
                                            ''),
                                  if (item.blogEntryItem?.attachments != null)
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  Text(
                                    item.messagePlainText ?? '',
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
                                  KaireteTextButton(
                                    onTap: () {
                                      controller.toDetail(item: item);
                                    },
                                    title: 'See detail',
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
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                                    title: '${item.commentCount} Replies',
                                  ),
                                  const KaireteIconButton(
                                    title: 'Like',
                                    icon: 'ic_like',
                                  ),
                                  KaireteIconButton(
                                    title: '${item.shareCount} Share',
                                    icon: 'ic_share',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            )
                          ],
                        ),
                      );
              },
            )),
    );
  }
}

class KaireteIconButton extends StatelessWidget {
  const KaireteIconButton({
    Key? key,
    this.title,
    this.icon,
  }) : super(key: key);

  final String? title;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: kPrimaryColor,
          border: Border.all(color: kBorderDefaultColor, width: 1)),
      child: Row(
        children: [
          SvgIcon(
            name: icon ?? 'ic_reply',
            width: 21,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            title ?? '0 replies',
            style: kTextRegularStyle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
