import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/features/newsfeed/controllers/reply_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

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
      ),
      // backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Obx(() => ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return CommentItem(
                  content: item.messageParsed ?? '',
                  name: item.username ??
                      ((item.user?.customFields?.firstName ?? '') +
                          (item.user?.customFields?.lastName ?? '')),
                  // child: Padding(
                  //   padding: const EdgeInsets.only(left: 4, top: 8),
                  //   child: CommentItem(
                  //     backgroundColor: Colors.grey.shade200,
                  //     isReplyAction: false, content: '',
                  //   ),
                  // ),
                );
              },
            )),
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
  }) : super(key: key);

  final Widget? child;
  final Color? backgroundColor;
  final bool isReplyAction;
  final String name;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: kBorderDefaultColor,
        ),
        color: backgroundColor,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KaireteCacheNetworkImage(
                url: '',
                width: 36,
                height: 36,
                isCircle: true,
                nameImage: ('AAA'),
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
                    // Text(
                    //   content,
                    //   maxLines: 5,
                    //   overflow: TextOverflow.ellipsis,
                    //   style: kTextMediumtStyle.copyWith(
                    //       color: Colors.black,
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w400),
                    // )0,
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
              KaireteIconButton(
                title: 'Like',
                icon: 'ic_like',
                onTap: () {},
              ),
              if (isReplyAction)
                const SizedBox(
                  width: 8,
                ),
              if (isReplyAction)
                KaireteIconButton(
                  title: 'Reply',
                  onTap: () {},
                  width: 60,
                ),
            ],
          ),
          if (child != null) child!
        ],
      ),
    );
  }
}
