import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:get/get.dart';
import 'package:kairete/helper/time.dart';

// ignore: must_be_immutable
class NewsFeedScreen extends StatelessWidget {
  NewsFeedScreen({Key? key}) : super(key: key);

  NewsFeedController controller = Get.put(NewsFeedController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Obx(() => ListView.builder(
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.withAlpha(60),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.user?.username ?? 'Empty name',
                                    style: kTextRegularStyle.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.itemCategory != null)
                                    const Icon(
                                      Icons.play_arrow,
                                      color: kPrimaryColor,
                                      size: 16,
                                    ),
                                  if (item.itemCategory != null)
                                    Text(
                                      item.itemCategory!,
                                      style: kTextRegularStyle.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: kPrimaryColor),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              RichText(
                                text: TextSpan(
                                  text: item.user?.username ?? 'Empty name',
                                  style: kTextMediumtStyle.copyWith(
                                      color: Colors.grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                  children: <TextSpan>[
                                    const TextSpan(
                                        text: ' • ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    TextSpan(
                                        text: TimeManager.instance
                                            .convertFromTimeStamp(
                                                timestamp: item.itemDate ?? 0),
                                        style: kTextMediumtStyle.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
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
                  InkWell(
                    onTap: () {
                      controller.toDetail(item: item);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? '',
                            style: kTextMediumtStyle.copyWith(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          if (item.blogEntryItem != null)
                            KaireteCacheNetworkImage(
                                url: item.blogEntryItem?.attachments![0]
                                        .thumbnailUrl ??
                                    ''),
                          const SizedBox(
                            height: 16,
                          ),
                          Text(
                            item.messagePlainText ?? '',
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: kTextMediumtStyle.copyWith(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            'See detail',
                            style: kTextMediumtStyle.copyWith(
                                color: kTextPrimaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    color: Colors.grey.withAlpha(60),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    height: 8,
                  )
                ],
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
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
          border: Border.all(color: kBorderDefaultColor, width: 1)),
      child: Row(
        children: [
          SvgIcon(
            name: icon ?? 'ic_reply',
            width: 21,
            height: 16,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            title ?? '0 replies',
            style: kTextRegularStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
