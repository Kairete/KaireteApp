import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:hashtagable/widgets/hashtag_text.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/forum/controllers/forum_detail_controller.dart';
import 'package:kairete/features/forum/models/forum_detail_model.dart';

import '../../../components/cache_image.dart';
import '../../../components/kairete_button.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

// ignore: must_be_immutable
class ForumDetailScreen extends StatelessWidget {
  ForumDetailScreen({Key? key}) : super(key: key);

  ForumDetailController controller = Get.put(ForumDetailController());
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(
        key: _key,
        isShowBack: true,
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
                        : ThreadItemCell(
                            item: item,
                            onTapComment: () {
                              controller.toComment(item: item);
                            },
                            onTapReactions: () {
                              controller.showReactionPopup(item: item);
                            },
                            onTapDetail: () {
                              controller.toDetail(item: item);
                            },
                            maxLine: 5,
                            onTapWatch: () {
                              controller.updateWatch(item: item);
                            },
                          );
                  },
                )),
        ),
      ),
    );
  }
}

class ThreadItemCell extends StatelessWidget {
  const ThreadItemCell({
    Key? key,
    required this.item,
    this.onTapComment,
    this.onTapReactions,
    this.maxLine,
    this.onTapDetail,
    this.isShowDetail = true,
    this.onTapWatch,
  }) : super(key: key);

  final Threads item;
  final Function? onTapComment;
  final Function? onTapReactions;
  final Function? onTapDetail;
  final int? maxLine;
  final bool isShowDetail;
  final Function? onTapWatch;

  @override
  Widget build(BuildContext context) {
    print(item.tags);
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                KaireteCacheNetworkImage(
                    url: item.user?.avatarUrls?.l ?? '',
                    width: 36,
                    height: 36,
                    isCircle: true,
                    nameImage: (item.username ?? '1')),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.username ?? '',
                        style: kTextMediumtStyle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      RichText(
                        text: TextSpan(
                          text: '',
                          style: kTextMediumtStyle.copyWith(
                              fontSize: 15, fontWeight: FontWeight.w600),
                          children: <TextSpan>[
                            TextSpan(
                                text: TimeManager.instance.convertFromTimeStamp(
                                    timestamp: item.lastPostDate ?? 0),
                                style: kTextMediumtStyle.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ActionsView(
                //   onTapWatch: () {
                //     if (onTapWatch != null) {
                //       onTapWatch!();
                //     }
                //   },
                //   isFollowed: item.user?.isFollowed,
                //   isIgnored: item.user?.isIgnored,
                //   isWatched: item.isWatched,
                // ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActionButton(
                      title: item.user?.isFollowed ?? false
                          ? 'Unfollow'
                          : 'Follow',
                      onTap: () {
                        if (onTapWatch != null) {
                          onTapWatch!();
                        }
                      },
                      // padding: EdgeInsets.only(bottom: 8),
                      icon: 'ic_ignore',
                      isActive: item.isWatched,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? '',
                  style: kTextTitle.copyWith(fontSize: 20),
                ),
                SizedBox(
                  height: 16,
                ),
                !isShowDetail
                    ? HtmlWidget(
                        (item.message)
                                ?.replaceAll("\\n", "")
                                .replaceAll("=\\  ", "=")
                                .replaceAll("g\\", "") ??
                            '',
                        textStyle: const TextStyle(fontSize: 17),
                      )
                    : Text(
                        item.message ?? '',
                        maxLines: maxLine,
                        overflow: TextOverflow.ellipsis,
                        style: kTextMediumtStyle.copyWith(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400),
                      ),
                if (isShowDetail)
                  const SizedBox(
                    height: 8,
                  ),
                if (item.tags != '')
                  Padding(
                    padding: const EdgeInsets.only(
                      // left: 16,
                      bottom: 8,
                    ),
                    child: HashTagText(
                      text: item.tags,
                      decoratedStyle:
                          TextStyle(fontSize: 16, color: kPrimaryColor),
                      basicStyle: TextStyle(fontSize: 16, color: Colors.black),
                      onTap: (text) {
                        print(text);
                      },
                    ),
                  ),
                if (isShowDetail)
                  KaireteTextButton(
                    onTap: () {
                      if (onTapDetail != null) {
                        onTapDetail!();
                      }
                    },
                    title: 'See detail',
                  ),
                const SizedBox(
                  height: 8,
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
                  title: '${item.replyCount ?? 0}',
                  onTap: () {
                    if (onTapComment != null) {
                      onTapComment!();
                    }
                  },
                ),
                KaireteIconButton(
                  title: 'Like',
                  icon: 'ic_like',
                  onTap: () {
                    if (onTapReactions != null) {
                      onTapReactions!();
                    }
                  },
                  url: item.isReation ? item.reactionIconUrl : null,
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
  }
}
