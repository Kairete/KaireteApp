import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_detail_controller.dart';

import '../../../components/cache_image.dart';
import '../../../components/reactions_view.dart';
import '../../../helper/time.dart';
import '../../../helper/user.dart';
import '../../newsfeed/screens/newsfeed_screen.dart';

// ignore: must_be_immutable
class BlogDetailScreen extends StatelessWidget {
  BlogDetailScreen({Key? key}) : super(key: key);

  BlogsDetailController controller = Get.put(BlogsDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Blogs Detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {},
                    child: KaireteCacheNetworkImage(
                      url: controller.item.value.user?.avatarUrls?.h ?? '',
                      width: 36,
                      height: 36,
                      isCircle: true,
                      nameImage:
                          controller.item.value.user?.customFields?.fullName ??
                              controller.item.value.user?.username ??
                              '',
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: TextSpan(
                        text: controller
                                .item.value.user?.customFields?.fullName ??
                            controller.item.value.user?.username ??
                            '',
                        style: kTextRegularStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                        children: [
                          if (controller.item.value.blog?.title != null)
                            const WidgetSpan(
                                child: Icon(
                              Icons.play_arrow,
                              color: kPrimaryColor,
                              size: 16,
                            )),
                          TextSpan(
                              text: controller.item.value.blog?.title ?? '',
                              style: kTextRegularStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                                fontSize: 16,
                              )),
                        ],
                      )),
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
                            TextSpan(
                                text: TimeManager.instance.convertFromTimeStamp(
                                    timestamp: controller.item.value
                                            .attachments?[0].attachDate ??
                                        0),
                                style: kTextMediumtStyle.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                )),
                            if (controller.item.value.blog?.title != null)
                              const TextSpan(text: ' - '),
                            if (controller.item.value.blog?.title != null)
                              TextSpan(
                                text:
                                    controller.item.value.category?.title ?? '',
                                style: kTextMediumtStyle.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimaryColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    controller.toCate();
                                  },
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                controller.item.value.title ?? '',
                style: kTextTitle.copyWith(color: Colors.black),
              ),
              const SizedBox(
                height: 16,
              ),
              if (controller.item.value.attachments != null)
                KaireteCacheNetworkImage(
                    url: controller.item.value.attachments![0].thumbnailUrl ??
                        ''),
              if (controller.item.value.attachments != null)
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
                height: 16,
              ),
              Obx(() => ReationsItemView(
                    commentCount: controller.item.value.commentCount,
                    onTapReply: () {
                      controller.toComment();
                    },
                    isShowLike: controller.item.value.user?.userId !=
                        UserManager.instance.userId,
                    onTapReactions: () {
                      controller.showReactions();
                    },
                    reactionIconUrl: controller.item.value.reactionIconUrl,
                    isShowShare: true,
                    shareCount: 0,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
