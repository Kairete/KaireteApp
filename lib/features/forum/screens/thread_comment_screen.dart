import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/forum/controllers/thread_comment_controller.dart';
import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../newsfeed/screens/reply_screen.dart';

// ignore: must_be_immutable
class ThreadCommentScreen extends StatelessWidget {
  ThreadCommentScreen({Key? key}) : super(key: key);

  ThreadCommentController controller = Get.put(ThreadCommentController());

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
                            isLikeAction: item.canReact ?? true,
                            urlReaction: item.reactionIconUrl,
                            reactions: item.reactions,
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
