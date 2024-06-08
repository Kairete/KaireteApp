import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';
import 'package:kairete/features/newsfeed/screens/reply_screen.dart';

import '../../../components/kairete_button.dart';
import '../../../components/kairete_form.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import 'package:get/get.dart';

import '../controllers/sub_reply_controller.dart';

class SubReplyScreen extends StatelessWidget {
  SubReplyScreen({Key? key}) : super(key: key);

  SubreplyController controller = Get.put(SubreplyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Replies',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
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
      bottomSheet: KaireteWriteTextField(
        onChanged: (p0) {
          controller.textOnChanged(text: p0);
        },
        onSend: () {
          controller.postComent();
        },
        controller: controller.textEditingController,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            //   child: KaireteTextField(
            //     onChanged: (value) {
            //       controller.textOnChanged(text: value);
            //     },
            //     hint: 'Write something…',
            //     maxLine: 3,
            //     borderColor: kPrimaryColor,
            //     controller: controller.textEditingController,
            //     textStyle: kTextRegularStyle.copyWith(
            //       fontWeight: FontWeight.w300,
            //       fontSize: 18,
            //     ),
            //   ),
            // ),
            Container(
              height: 12,
              color: kBorderDefaultColor,
            ),
            Expanded(
                child: Obx(() => Padding(
                      padding: EdgeInsets.only(bottom: kBottomSafea + 80),
                      child: Column(
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
                            subComment: controller.items,
                            onTapLikeSubComment: (p0) {
                              controller.showReactions(
                                  commentId: p0.commentId ?? 0);
                            },
                          ),
                          // Expanded(
                          //     child: ListView.builder(
                          //   itemCount: controller.items.length,
                          //   itemBuilder: (context, index) {
                          //     final item = controller.items[index];
                          //     return Padding(
                          //       padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          //       child: Column(
                          //         children: [
                          //           CommentItem(
                          //             content: item.messageParsed ?? '',
                          //             name: item.user?.username ?? '',
                          //             avatar: item.user?.avatarUrls?.h,
                          //             isLikeAction: item.canReact ?? true,
                          //             isReplyAction: false,
                          //             backgroundColor: const Color(0xFFF5F5F5),
                          //             reactions: item.reactions,
                          //             urlReaction: item.reactionIconUrl,
                          //             onTapLike: () {
                          //               controller.showReactions(
                          //                   commentId: item.commentId ?? 0);
                          //             },
                          //           ),
                          //           Container(
                          //             height: 0.5,
                          //             color: kBorderDefaultColor,
                          //           )
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // )),
                        ],
                      ),
                    )))
          ],
        ),
      ),
    );
  }
}
