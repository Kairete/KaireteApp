import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../newsfeed/screens/reply_screen.dart';
import '../controllers/thread_reply_controller.dart';

class ThreadReplyScreen extends StatelessWidget {
  ThreadReplyScreen({Key? key}) : super(key: key);

  ThreadReplyController controller = Get.put(ThreadReplyController());

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Container(
              height: 12,
              color: kBorderDefaultColor,
            ),
            Expanded(
                child: Obx(() => Column(
                      children: [
                        CommentItem(
                          content: controller.item?.messageParsed ?? '',
                          name: controller.item?.user?.username ?? '',
                          avatar: controller.item?.user?.avatarUrls?.h,
                          isReplyAction: false,
                          reactions: controller.item?.reactions,
                          urlReaction: controller.item?.reactionIconUrl,
                          isLikeAction: controller.item?.canReact ?? true,
                          onTapLike: () {
                            controller.showReactions(
                                commentId: controller.item?.commentId ?? 0);
                          },
                        ),
                        Expanded(
                            child: ListView.builder(
                          itemCount: controller.items.length,
                          itemBuilder: (context, index) {
                            final item = controller.items[index];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                              child: Column(
                                children: [
                                  CommentItem(
                                    content: item.messageParsed ?? '',
                                    name: item.user?.username ?? '',
                                    avatar: item.user?.avatarUrls?.h,
                                    isReplyAction: false,
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    reactions: item.reactions,
                                    urlReaction: item.reactionIconUrl,
                                    isLikeAction: item.canReact ?? true,
                                    onTapLike: () {
                                      controller.showReactions(
                                          commentId: item.commentId ?? 0);
                                    },
                                  ),
                                  Container(
                                    height: 0.5,
                                    color: kBorderDefaultColor,
                                  )
                                ],
                              ),
                            );
                          },
                        )),
                      ],
                    )))
          ],
        ),
      ),
    );
  }
}
