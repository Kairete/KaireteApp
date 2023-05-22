import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_button.dart';
import 'package:kairete/components/kairete_icon.dart';
import 'package:kairete/features/groups/controllers/group_controller.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/color.dart';

// ignore: must_be_immutable
class GroupScreen extends StatelessWidget {
  GroupScreen({Key? key}) : super(key: key);

  GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarCustom('Groups'),
      body: SafeArea(
        child: Obx(() => ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: controller.items.length,
              separatorBuilder: (context, index) {
                return Container(
                  height: 16,
                );
              },
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return InkWell(
                  onTap: () {
                    controller.toDetail(item: item);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                    ),
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color:
                                    HexColor(item.dynamicColor?.bgColor ?? ''),
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8))),
                            height: 120,
                            child: Center(
                              child: Text(
                                item.name ?? '',
                                style: kTextTitle.copyWith(
                                  color:
                                      HexColor(item.dynamicColor?.color ?? ''),
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
                                    KaireteCacheNetworkImage(
                                      height: 80,
                                      width: 80,
                                      url: item.avatarUrl ?? '',
                                      nameImage: item.name,
                                      isCircle: false,
                                      fontSize: 40,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              countItem(
                                                  item.viewCount.toString(),
                                                  'ic_view_eye'),
                                              countItem(
                                                  item.memberCount.toString(),
                                                  'ic_friends'),
                                              countItem(
                                                  item.discussionCount
                                                      .toString(),
                                                  'ic_comment'),
                                              countItem(
                                                  item.eventCount.toString(),
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
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              item.shortDescription ?? '',
                              style: kTextRegularStyle,
                            ),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              KairetePrimaryButton(
                                onTap: () {
                                  controller.groupActions(item: item);
                                },
                                title: (item.isJoined ?? false)
                                    ? 'Leave group'
                                    : 'Join group',
                                width: 150,
                                height: 40,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          )
                        ],
                      ),
                    ),
                  ),
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
