import 'package:flutter/material.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_detail_controller.dart';

import '../../../components/cache_image.dart';
import '../../../components/reactions_view.dart';
import '../../../helper/time.dart';

// ignore: must_be_immutable
class BlogDetailScreen extends StatelessWidget {
  BlogDetailScreen({Key? key}) : super(key: key);

  BlogsDetailController controller = Get.put(BlogsDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Blogs Detail detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.item?.category?.title ?? '',
                style: kTextMediumtStyle.copyWith(
                  color: kTextCriticalColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                controller.item?.title ?? '',
                style: kTextTitle.copyWith(color: kTextCriticalColor),
              ),
              const SizedBox(
                height: 8,
              ),
              RichText(
                  text: TextSpan(
                text: controller.item?.user?.customFields?.fullName ??
                    'Empty name',
                style: kTextMediumtStyle.copyWith(
                    color: kTextCriticalColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              )),
              const SizedBox(
                height: 16,
              ),
              if (controller.item?.attachments != null)
                KaireteCacheNetworkImage(
                    url: controller.item?.attachments![0].thumbnailUrl ?? ''),
              const SizedBox(
                height: 16,
              ),
              Text(
                controller.item?.messagePlainText ?? '',
                style: kTextMediumtStyle.copyWith(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 16,
              ),
              if (controller.item?.reactions != null)
                ReactionsItemView(reactions: controller.item?.reactions ?? [])
            ],
          ),
        ),
      ),
    );
  }
}
