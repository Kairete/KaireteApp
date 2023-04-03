import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/features/newsfeed/controllers/reply_controller.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import 'package:get/get.dart';

class ReplyScreen extends StatelessWidget {
  ReplyScreen({Key? key}) : super(key: key);

  ReplyController controller = Get.put(ReplyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Replies',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
        actions: [
          Obx(() => KairetePrimaryButton(
                onTap: () {
                  controller.postComent();
                },
                title: 'POST',
                width: 100,
                state: controller.isEnable.value
                    ? StateButton.active
                    : StateButton.disable,
              ))
        ],
      ),
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: KaireteTextField(
                onChanged: (value) {
                  controller.textOnChanged(text: value);
                },
                hint: 'Write something…',
                maxLine: 3,
                borderColor: kPrimaryColor,
                controller: controller.textEditingController,
              ),
            ),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: controller.items.length,
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      return Column(
                        children: [
                          CommentItem(
                            content: item.messageParsed ?? '',
                            name: item.user?.username ?? 'Unknown',
                            avatar: item.user?.avatarUrls?.h,
                            onTapReply: () {
                              controller.toSubReply(item: item);
                            },
                            urlReaction: item.reactionIconUrl,
                            reactions: item.reactions,
                            isLikeAction: item.canReact ?? true,
                            onTapLike: () {
                              controller.showReactions(
                                  commentId: item.commentId ?? 0);
                            },
                          ),
                          Container(
                            height: 0.5,
                            color: Colors.grey,
                          )
                        ],
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  const CommentItem({
    Key? key,
    this.child,
    this.backgroundColor,
    this.isReplyAction = true,
    required this.name,
    required this.content,
    this.avatar,
    this.onTapReply,
    this.onTapLike,
    this.isBorder = false,
    this.reactions,
    this.urlReaction,
    this.isLikeAction = true,
  }) : super(key: key);

  final Widget? child;
  final Color? backgroundColor;
  final bool isReplyAction;
  final String name;
  final String content;
  final String? avatar;
  final Function? onTapReply;
  final Function? onTapLike;
  final bool isBorder;
  final List<Reactions>? reactions;
  final String? urlReaction;
  final bool isLikeAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: backgroundColor ?? Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KaireteCacheNetworkImage(
                url: avatar ?? '',
                width: 36,
                height: 36,
                isCircle: true,
                nameImage: name,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: kTextRegularStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    HtmlWidget(
                      content
                          .replaceAll("\n", "")
                          .replaceAll("=\\  ", "=")
                          .replaceAll("g\\", ""),
                      textStyle: const TextStyle(fontSize: 17),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isLikeAction)
                KaireteIconButton(
                  title: 'Like',
                  icon: 'ic_like',
                  color: backgroundColor ?? Colors.white,
                  textColor: kPrimaryColor,
                  url: urlReaction,
                  onTap: () {
                    if (onTapLike != null) {
                      onTapLike!();
                    }
                  },
                ),
              if (isReplyAction)
                const SizedBox(
                  width: 8,
                ),
              if (isReplyAction)
                KaireteIconButton(
                  title: 'Reply',
                  onTap: () {
                    if (onTapReply != null) {
                      onTapReply!();
                    }
                  },
                  width: 60,
                  color: backgroundColor ?? Colors.white,
                  textColor: kPrimaryColor,
                ),
            ],
          ),
          if (child != null) child!,
          if (reactions != null) ReactionsItemView(reactions: reactions ?? []),
          if (reactions != null)
            const SizedBox(
              height: 8,
            ),
        ],
      ),
    );
  }
}
