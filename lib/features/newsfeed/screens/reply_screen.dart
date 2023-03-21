import 'package:flutter/material.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/features/newsfeed/controllers/reply_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import 'package:get/get.dart';

class ReplyScreen extends StatelessWidget {
  ReplyScreen({Key? key}) : super(key: key);

  ReplyController cotroller = Get.put(ReplyController());

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
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return CommentItem(
              child: Padding(
                padding: EdgeInsets.only(left: 4, top: 8),
                child: CommentItem(
                  backgroundColor: Colors.grey.shade200,
                  isReplyAction: false,
                ),
              ),
            );
          },
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
  }) : super(key: key);

  final Widget? child;
  final Color? backgroundColor;
  final bool isReplyAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
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
              KaireteCacheNetworkImage(
                url: '',
                width: 36,
                height: 36,
                isCircle: true,
                nameImage: ('AAA'),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'asdasd',
                      style: kTextRegularStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Davvero contenta per te Frà. Facebook mi ha a tua scelta di andartene e di emigrare su FB',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: kTextMediumtStyle.copyWith(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
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
                SizedBox(
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
