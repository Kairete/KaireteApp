import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/features/articles/controllers/articles_detail_controller.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import 'package:kairete/helper/user.dart';

import '../../../components/cache_image.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import 'package:get/get.dart';

import '../../../helper/time.dart';

// ignore: must_be_immutable
class ArticlesDetailScreen extends StatelessWidget {
  ArticlesDetailScreen({Key? key}) : super(key: key);

  ArticlesDetailController controller = Get.put(
    ArticlesDetailController(),
  );
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.removeStack();
        return true;
      },
      child: Scaffold(
        key: _key,
        appBar: baseAppBar(
            key: _key,
            isShowBack: true,
            onTapBack: () {
              controller.removeStack();
            }),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.toCategory();
                      },
                      child: Text(
                        controller.item.value.category?.title ?? '',
                        style: kTextTitle.copyWith(
                          color: kTextCriticalColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      controller.item.value.title ?? '',
                      style: kTextTitle.copyWith(color: kTextCriticalColor),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    RichText(
                      text: TextSpan(
                        text: controller.item.value.user?.username ?? '',
                        style: kTextMediumtStyle.copyWith(
                          color: Colors.grey,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                              text: ' • ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text: TimeManager.instance.convertFromTimeStamp(
                                timestamp: controller.item.value.attachments?[0]
                                        .attachDate ??
                                    0),
                            style: kTextMediumtStyle.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(
                              text: ' • ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text:
                                'Views: ${controller.item.value.viewCount ?? 0}',
                            style: kTextMediumtStyle.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const TextSpan(
                              text: ' • ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                            text:
                                'Comments: ${controller.item.value.commentCount ?? 0}',
                            style: kTextMediumtStyle.copyWith(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (controller.item.value.attachments != null)
                      KaireteCacheNetworkImage(
                          url: controller
                                  .item.value.attachments![0].thumbnailUrl ??
                              ''),
                    const SizedBox(
                      height: 16,
                    ),
                    HtmlWidget(
                      controller.item.value.messageParsed
                              ?.replaceAll("\n", "")
                              .replaceAll("=\\  ", "=")
                              .replaceAll("g\\", "") ??
                          '',
                      textStyle: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (controller.item.value.reactions != null)
                      ReactionsItemView(
                          reactions: controller.item.value.reactions ?? []),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    ReationsItemView(
                      commentCount: controller.newfeed.value.commentCount,
                      onTapReply: () {
                        controller.toReplies();
                      },
                      isShowLike: controller.newfeed.value.user?.userId !=
                          UserManager.instance.userId,
                      onTapReactions: () {
                        controller.showReactionPopup();
                      },
                      reactionIconUrl: controller.newfeed.value.reactionIconUrl,
                      isShowShare: true,
                      shareCount: controller.newfeed.value.shareCount,
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
