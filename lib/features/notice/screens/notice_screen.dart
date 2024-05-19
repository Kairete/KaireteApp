import 'package:flutter/material.dart';
import 'package:kairete/features/notice/controllers/notice_controller.dart';
import 'package:get/get.dart';

import '../../../components/cache_image.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';

// ignore: must_be_immutable
class NoticeScreen extends StatelessWidget {
  NoticeScreen({super.key});

  NoticeController controller = Get.put(NoticeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notices',
          style: kTextTitle.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Obx(() => ListView.separated(
              itemCount: controller.notices.length,
              itemBuilder: (context, index) {
                final item = controller.notices[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KaireteCacheNetworkImage(
                      url: item.user?.avatarUrls?.l ?? '',
                      width: 24,
                      height: 24,
                      isCircle: true,
                      nameImage: item.username,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.alertText ?? '',
                            style: kTextRegularStyle.copyWith(
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            TimeManager.instance.convertFromTimeStamp(
                                timestamp: item.eventDate ?? 0),
                            style: kTextMediumtStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            )),
      ),
    );
  }
}
