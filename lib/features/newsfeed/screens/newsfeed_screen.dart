import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_controller.dart';
import 'package:get/get.dart';
import 'package:kairete/helper/time.dart';
import 'package:kairete/helper/user.dart';

import '../../../components/kairete_button.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/key_constant.dart';
import '../../../local/data_local.dart';
import '../models/newsfeed_model.dart';

// ignore: must_be_immutable
class NewsFeedScreen extends StatelessWidget {
  NewsFeedScreen({Key? key}) : super(key: key);

  NewsFeedController controller = Get.put(NewsFeedController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.items.isEmpty
        ? SizedBox()
        : NewsfeedListItem(
            items: controller.items.value,
            onCreate: () {
              controller.toCreate();
            },
            onTapDetail: (item) {
              controller.toDetail(item: item);
            },
            onFilter: () {
              controller.onFilter();
            },
            onTabFilter: (value) {
              controller.onSelectedTabFilter(index: value);
            },
          ));
  }
}

class NewsfeedListItem extends GetView<NewsFeedController> {
  const NewsfeedListItem({
    Key? key,
    required this.items,
    this.onTapDetail,
    this.onCreate,
    this.isShowCreate = true,
    this.onFilter,
    this.onTabFilter,
  }) : super(key: key);

  final List<NewsfeedModel> items;
  final Function(NewsfeedModel)? onTapDetail;
  final Function? onCreate;
  final bool isShowCreate;
  final Function? onFilter;
  final Function(int)? onTabFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          final originIndex = index == 0 ? 0 : index - 1;
          final item = items[originIndex];
          return index == 0
              ? (isShowCreate
                  ? GestureDetector(
                      onTap: () {
                        if (onCreate != null) {
                          onCreate!();
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
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
                          Obx(() => Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FilterButton(
                                      icon: 'ic_user',
                                      onTap: () {
                                        if (onTabFilter != null) {
                                          onTabFilter!(0);
                                        }
                                      },
                                      isActive:
                                          controller.selectedTabFilter.value ==
                                              0,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    FilterButton(
                                      icon: 'ic_news',
                                      onTap: () {
                                        if (onTabFilter != null) {
                                          onTabFilter!(1);
                                        }
                                      },
                                      isActive:
                                          controller.selectedTabFilter.value ==
                                              1,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    FilterButton(
                                      icon: 'ic_friends',
                                      onTap: () {
                                        if (onTabFilter != null) {
                                          onTabFilter!(2);
                                        }
                                      },
                                      isActive:
                                          controller.selectedTabFilter.value ==
                                              2,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    FilterButton(
                                      icon: 'ic_home',
                                      onTap: () {
                                        if (onTabFilter != null) {
                                          onTabFilter!(3);
                                        }
                                      },
                                      isActive:
                                          controller.selectedTabFilter.value ==
                                              3,
                                    ),
                                    Expanded(child: Container()),
                                    InkWell(
                                      onTap: () {
                                        controller.onSort();
                                      },
                                      child: Icon(
                                        Icons.sort_rounded,
                                        color: kPrimaryColor,
                                        size: 25,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (onFilter != null) {
                                          onFilter!();
                                        }
                                      },
                                      child: SvgIcon(
                                        name: 'ic_filter',
                                        color: kPrimaryColor,
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                        ],
                      ),
                    )
                  : SizedBox())
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
                                nameImage: (item.user?.customFields?.fullName ??
                                    item.user?.username ??
                                    '')),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: item.user?.customFields?.fullName ??
                                          item.user?.username ??
                                          '',
                                      style: kTextRegularStyle.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                      children: [
                                        if (item.blogEntryItem?.blog?.title !=
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
                                            style: kTextRegularStyle.copyWith(
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
                                                        item.itemDate ?? 0),
                                            style: kTextMediumtStyle.copyWith(
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
                        padding: const EdgeInsets.only(left: 16, right: 16),
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
                                    '',
                              ),
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
                                if (onTapDetail != null) {
                                  onTapDetail!(item);
                                }
                              },
                              title: 'See detail',
                            ),
                            if (item.reactions != null)
                              ReactionsItemView(reactions: item.reactions ?? [])
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            KaireteIconButton(
                              title: '${item.commentCount} Replies',
                            ),
                            if (item.user?.userId !=
                                LocalManager.instance
                                    .read(key: PreferencesKey.token))
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
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class FilterButton extends StatelessWidget {
  FilterButton({
    Key? key,
    this.icon,
    this.onTap,
    this.isActive = false,
  }) : super(key: key);

  final String? icon;
  final Function? onTap;
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: kBorderDefaultColor,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isActive ? kPrimaryColor : Colors.white,
        ),
        child: SvgIcon(
          name: icon ?? 'ic_home',
          width: 25,
          height: 25,
          color: isActive ? Colors.white : kPrimaryColor,
        ),
      ),
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
