import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kairete/features/articles/controllers/articles_detail_controller.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';

import '../../../components/cache_image.dart';
import '../../../components/reactions_view.dart';
import '../../../constants/color_constant.dart';
import '../../../constants/font_constant.dart';
import 'package:get/get.dart';

import '../../../helper/time.dart';

// ignore: must_be_immutable
class ArticlesDetailScreen extends StatelessWidget {
  ArticlesDetailScreen({Key? key}) : super(key: key);

  ArticlesDetailController controller = Get.put(ArticlesDetailController());
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(key: _key, isShowBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.item.value.title ?? '',
                    style: kTextTitle.copyWith(color: kTextCriticalColor),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  RichText(
                    text: TextSpan(
                      text:
                          controller.item.value.user?.customFields?.fullName ??
                              controller.item.value.user?.username ??
                              '',
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
                              timestamp: controller
                                      .item.value.attachments?[0].attachDate ??
                                  0),
                          style: kTextMediumtStyle.copyWith(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (controller.item.value.attachments != null)
                    KaireteCacheNetworkImage(
                        url: controller
                                .item.value.attachments![0].thumbnailUrl ??
                            ''),
                  const SizedBox(
                    height: 16,
                  ),
                  HtmlWidget(
                    controller.item.value.messageParsed
                            ?.replaceAll("\n", "")
                            .replaceAll("=\\  ", "=")
                            .replaceAll("g\\", "") ??
                        '',
                    textStyle: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  if (controller.item.value.reactions != null)
                    ReactionsItemView(
                        reactions: controller.item.value.reactions ?? [])
                ],
              )),
        ),
      ),
    );
  }
}
