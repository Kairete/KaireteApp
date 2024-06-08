import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_textfield_action.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/blogs/controllers/blog_reply_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../newsfeed/screens/reply_screen.dart';

class BlogReplyScreen extends StatelessWidget {
  BlogReplyScreen({Key? key}) : super(key: key);

  BlogReplyController controller = Get.put(BlogReplyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Replies',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
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
        child: Padding(
          padding: EdgeInsets.only(bottom: kBottomSafea + 80),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                            //       padding:
                            //           const EdgeInsets.fromLTRB(60, 0, 12, 0),
                            //       child: Column(
                            //         children: [
                            //           CommentItem(
                            //             content: item.messageParsed ?? '',
                            //             name: item.user?.username ?? '',
                            //             avatar: item.user?.avatarUrls?.h,
                            //             isLikeAction: item.canReact ?? true,
                            //             isReplyAction: false,
                            //             backgroundColor: Colors.white,
                            //             reactions: item.reactions,
                            //             urlReaction: item.reactionIconUrl,
                            //             onTapLike: () {
                            //               controller.showReactions(
                            //                   commentId: item.commentId ?? 0);
                            //             },
                            //           ),
                            //         ],
                            //       ),
                            //     );
                            //   },
                            // )),
                          ],
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
