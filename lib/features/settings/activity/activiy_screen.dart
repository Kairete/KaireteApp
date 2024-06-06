import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/features/settings/activity/activity_controller.dart';

class ActivityScreen extends StatelessWidget {
  final ActivityController controller = Get.put(ActivityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity'),
        backgroundColor: kPrimaryColor,
      ),
      body: Obx(() => ListView.separated(
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = controller.items[index];
              return Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KaireteCacheNetworkImage(
                      url: item.avatarUrls?.h ?? '',
                      nameImage: item.username,
                      width: 35,
                      height: 35,
                      isCircle: true,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.username ?? '',
                                style: kTextTitle.copyWith(
                                  fontSize: 16,
                                  color: kTextDefaultColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item.userTitle ?? '',
                            style: kTextSubTitle.copyWith(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              text: item.getSubText(),
                              style: kTextRegularStyle.copyWith(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            itemCount: controller.items.length,
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          )),
    );
  }
}
