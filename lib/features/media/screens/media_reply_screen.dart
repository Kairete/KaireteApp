import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/media/controllers/media_reply_controller.dart';
import 'package:kairete/features/newsfeed/screens/reply_screen.dart';

class MediaReplyScreen extends StatelessWidget {
  MediaReplyScreen({Key? key}) : super(key: key);

  MediaReplyController controller = Get.put(MediaReplyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Replies',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        // actions: [
        //   Obx(() => KairetePrimaryButton(
        //         onTap: () {
        //           controller.postComent();
        //         },
        //         title: 'POST',
        //         width: 100,
        //         state: controller.isEnable.value
        //             ? StateButton.active
        //             : StateButton.disable,
        //       ))
        // ],
      ),
      // backgroundColor: Colors.white,
      bottomSheet: KaireteWriteTextField(
        onChanged: (p0) {
          // controller.textOnChanged(text: p0);
        },
        onSend: () {
          controller.postComent();
        },
        controller: controller.textEditingController,
      ),
      body: SafeArea(
        child: Obx(() => Container(
              color: Colors.white,
              padding: EdgeInsets.only(bottom: kBottomSafea + 80),
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
                        onTapReply: () {},
                        urlReaction: item.reactionIconUrl,
                        reactions: item.reactions,
                        isLikeAction: item.canReact ?? true,
                        onTapLike: () {
                          // controller.showReactionPopup(item: item);
                        },
                        subComment: item.reply,
                        // elevation: 0,
                      ),
                    ],
                  );
                },
              ),
            )),
      ),
    );
  }
}
