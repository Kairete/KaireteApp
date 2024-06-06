import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_comment_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../newsfeed/screens/reply_screen.dart';

class BlogCommentScreen extends StatelessWidget {
  BlogCommentScreen({Key? key}) : super(key: key);

  BlogCommentController controller = Get.put(BlogCommentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: KaireteWriteTextField(
        onChanged: (p0) {
          controller.textOnChanged(text: p0);
        },
        onSend: () {
          controller.postComent();
        },
        controller: controller.textEditingController,
      ),
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Replies',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Obx(() => Container(
              color: Colors.white,
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
                      if (item.reply != null)
                        Column(
                          children: item.reply!
                              .map<Padding>((data) => Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(60, 0, 12, 0),
                                    child: Column(
                                      children: [
                                        CommentItem(
                                          content: data.messageParsed ?? '',
                                          name: data.user?.username ?? '',
                                          avatar: data.user?.avatarUrls?.h,
                                          isLikeAction: data.canReact ?? true,
                                          isReplyAction: false,
                                          backgroundColor: Colors.white,
                                          reactions: data.reactions,
                                          urlReaction: data.reactionIconUrl,
                                          onTapLike: () {
                                            controller.showReactions(
                                                commentId: data.commentId ?? 0);
                                          },
                                        )
                                      ],
                                    ),
                                  ))
                              .toList(),
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
