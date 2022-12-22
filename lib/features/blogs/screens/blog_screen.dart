import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';

import '../../../components/cache_image.dart';
import '../../../helper/time.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<BlogController>(
      init: BlogController(),
      builder: (controller) {
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Column(
              children: [
                Container(
                  height: 16,
                  color: kBorderDefaultColor,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.category?.title ?? '',
                        style: kTextRegularStyle.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        item.title ?? '',
                        style: kTextTitle,
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              item.user?.customFields?.fullName ?? 'Empty name',
                          style: kTextMediumtStyle.copyWith(
                            color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          children: <TextSpan>[
                            const TextSpan(
                                text: ' • ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text: TimeManager.instance.convertFromTimeStamp(
                                    timestamp: item.user?.lastActivity ?? 0),
                                style: kTextMediumtStyle.copyWith(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      if (item.coverImage != null)
                        KaireteCacheNetworkImage(
                            url: item.coverImage?.thumbnailUrl ?? ''),
                      const SizedBox(
                        height: 16,
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
                      const SizedBox(
                        height: 16,
                      ),
                      KaireteTextButton(
                        onTap: () {
                          controller.toDetail(item: item);
                        },
                        title: 'See detail',
                      )
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
