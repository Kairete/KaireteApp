import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_detail_controller.dart';

import '../../../components/cache_image.dart';
import '../../../components/reactions_view.dart';
import '../../../helper/time.dart';

// ignore: must_be_immutable
class NewsfeedDetailScreen extends StatelessWidget {
  NewsfeedDetailScreen({Key? key}) : super(key: key);

  NewsfeedDetailController controller = Get.put(NewsfeedDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Newsfeed detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.item?.blogEntryItem?.category?.title ?? '',
                style: kTextMediumtStyle.copyWith(
                  color: kTextCriticalColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
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
                text: controller.item?.user?.username ?? 'Empty name',
                style: kTextMediumtStyle.copyWith(
                    color: kTextCriticalColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
                children: <TextSpan>[
                  const TextSpan(
                      text: ' • ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: TimeManager.instance.convertFromTimeStamp(
                          timestamp: controller.item?.itemDate ?? 0),
                      style: kTextMediumtStyle.copyWith(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              )),
              const SizedBox(
                height: 16,
              ),
              if (controller.item?.blogEntryItem != null)
                KaireteCacheNetworkImage(
                    url: controller.item?.blogEntryItem?.attachments?[0]
                            .thumbnailUrl ??
                        ''),
              const SizedBox(
                height: 16,
              ),
              HtmlWidget(
                (controller.item?.blogEntryItem?.messageParsed ??
                            controller.item?.messageParsed)
                        ?.replaceAll("\n", "")
                        .replaceAll("=\\  ", "=")
                        .replaceAll("g\\", "") ??
                    '',
                textStyle: TextStyle(fontSize: 17),
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
