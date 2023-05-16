import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/features/groups/controllers/group_controller.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import 'package:kairete/features/groups/models/group_model/group.dart';

// ignore: must_be_immutable
class GroupScreen extends StatelessWidget {
  GroupScreen({Key? key}) : super(key: key);

  GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom('Group'),
      body: SafeArea(
        child: Obx(() => ListView.separated(
              itemCount: controller.items.length,
              separatorBuilder: (context, index) {
                return Container(
                  height: 16,
                );
              },
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.green,
                      height: 120,
                      child: Center(
                        child: Text(
                          item.name ?? '',
                          style: kTextTitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        right: 16,
                        bottom: 8,
                        left: 16,
                      ),
                      color: kEEF6FDColor,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 8,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80,
                                width: 80,
                                color: Colors.amber,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name ?? '',
                                      style: kTextMediumtStyle.copyWith(
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    const Text(
                                      'Public Group',
                                      style: kTextRegularStyle,
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        countItem(item.viewCount.toString(),
                                            'ic_view_eye'),
                                        countItem(item.memberCount.toString(),
                                            'ic_friends'),
                                        countItem(
                                            item.discussionCount.toString(),
                                            'ic_comment'),
                                        countItem(item.eventCount.toString(),
                                            'ic_calendar')
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        item.shortDescription ?? '',
                        style: kTextRegularStyle,
                      ),
                    )
                  ],
                );
              },
            )),
      ),
    );
  }

  Row countItem(String title, String icon) {
    return Row(
      children: [
        SvgIcon(
          name: icon,
          width: 20,
          height: 20,
        ),
        const SizedBox(
          width: 2,
        ),
        Text(title)
      ],
    );
  }
}

AppBar AppbarCustom(String title) {
  return AppBar(
    backgroundColor: kPrimaryColor,
    title: Text(
      title,
      style: kTextHeadingStyle.copyWith(color: Colors.white),
    ),
  );
}
