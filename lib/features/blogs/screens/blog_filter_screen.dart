import 'package:flutter/material.dart';
import 'package:kairete/features/blogs/controllers/blog_filter_controller.dart';
import 'package:get/get.dart';

import '../../../components/cache_image.dart';
import '../../../components/kairete_button.dart';
import '../../../constants/color.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';

// ignore: must_be_immutable
class BlogFilterScreen extends StatelessWidget {
  BlogFilterScreen({Key? key}) : super(key: key);

  BlogFilterController controller = Get.put(BlogFilterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          controller.cate?.title ?? '',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: Obx(() => ListView.builder(
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
                          item.blog?.title ?? '',
                          style: kTextRegularStyle.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              fontStyle: FontStyle.italic),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: TimeManager.instance
                                      .convertFromTimeStamp(
                                          timestamp:
                                              item.attachments?[0].attachDate ??
                                                  0),
                                  style: kTextMediumtStyle.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              const TextSpan(
                                  text: ' • ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: item.category?.title ?? '',
                                  style: kTextMediumtStyle.copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimaryColor,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        if (item.coverImage != null)
                          KaireteCacheNetworkImage(
                              url: item.coverImage?.thumbnailUrl ?? ''),
                        if (item.coverImage != null)
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
          )),
    );
  }
}
