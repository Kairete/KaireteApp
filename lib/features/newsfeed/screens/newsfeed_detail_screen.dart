import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_detail_controller.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import '../../../components/reactions_view.dart';
import '../../../helper/user.dart';

// ignore: must_be_immutable
class NewsfeedDetailScreen extends StatelessWidget {
  NewsfeedDetailScreen({Key? key}) : super(key: key);

  NewsfeedDetailController controller = Get.put(NewsfeedDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Newsfeed detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderInfoCellWithAvatar(
                    userName:
                        controller.item.value.user?.username ?? 'Empty name',
                    onTapAvatar: () {},
                    blogTitle: controller.item.value.blogEntryItem?.blog?.title,
                    groupTitle:
                        controller.item.value.groupPostItem?.group?.name,
                    authorBlog: controller.item.value.type ==
                            ContentTypeNewFeed.blogEntry
                        ? controller.item.value.blogEntryItem?.user?.username
                        : null,
                    date: controller.item.value.itemDate,
                    titleCate: '',
                    avatar: controller.item.value.user?.avatarUrls?.h,
                    nameImage:
                        (controller.item.value.user?.customFields?.fullName ??
                            controller.item.value.user?.username ??
                            ''),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (controller.item.value.title != '' &&
                      controller.item.value.groupPostItem == null &&
                      controller.item.value.type !=
                          ContentTypeNewFeed.tlGroupPost)
                    Text(
                      (controller.item.value.title != '' &&
                              controller.item.value.groupPostItem == null &&
                              controller.item.value.type !=
                                  ContentTypeNewFeed.tlGroupPost)
                          ? (controller.item.value.title ?? '')
                          : '',
                      style: kTextMediumtStyle.copyWith(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  HtmlWidget(
                    (controller.item.value.blogEntryItem?.messageParsed ??
                                controller.item.value.messageParsed)
                            ?.replaceAll("\\n", "")
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
                  ReationsItemView(
                      commentCount: controller.item.value.commentCount,
                      onTapReply: () {
                        controller.toReplies();
                      },
                      isShowLike: controller.item.value.user?.userId !=
                          UserManager.instance.userId,
                      onTapReactions: () {
                        controller.showReactionPopup();
                      },
                      reactionIconUrl: controller.item.value.reactionIconUrl,
                      isShowShare: true,
                      shareCount: controller.item.value.shareCount)
                ],
              )),
        ),
      ),
    );
  }
}
