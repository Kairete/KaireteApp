import 'package:flutter/material.dart';
import 'package:hashtagable/widgets/hashtag_text.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/features/articles/controllers/articles_controller.dart';
import 'package:get/get.dart';
import '../../../components/action_item.dart';
import '../../../components/cache_image.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';

// ignore: must_be_immutable
class ArticlesScreen extends StatelessWidget {
  ArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetX<ArticlesController>(
        init: ArticlesController(),
        builder: (controller) {
          return Container(
            // padding: EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return InkWell(
                  onTap: () {
                    controller.toDetail(item: item);
                  },
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 16,
                            color: kBorderDefaultColor,
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.category?.title ?? '',
                                        style: kTextRegularStyle.copyWith(
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 17,
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    ActionsView(
                                      onTapWatch: () {
                                        controller.updateWatch(item: item);
                                      },
                                      isFollowed: item.user?.isFollowed,
                                      isIgnored: item.user?.isIgnored,
                                      isWatched: item.isWatched,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: item.user?.customFields?.fullName ??
                                        item.user?.username ??
                                        '',
                                    style: kTextMediumtStyle.copyWith(
                                      color: Colors.grey,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    children: <TextSpan>[
                                      const TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      TextSpan(
                                        text: TimeManager.instance
                                            .convertFromTimeStamp(
                                                timestamp: item.attachments?[0]
                                                        .attachDate ??
                                                    0),
                                        style: kTextMediumtStyle.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                if (item.tags != '')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                    ),
                                    child: HashTagText(
                                      text: item.tags,
                                      decoratedStyle: TextStyle(
                                          fontSize: 16, color: kPrimaryColor),
                                      basicStyle: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      onTap: (text) {
                                        print(text);
                                      },
                                    ),
                                  ),
                                SizedBox(
                                  height: 16,
                                ),
                                KaireteCacheNetworkImage(
                                  url: item.coverImage?.thumbnailUrl ?? '',
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  item.title ?? '',
                                  style: kTextTitle,
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  item.messagePlainText ?? '',
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  style: kTextMediumtStyle.copyWith(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
