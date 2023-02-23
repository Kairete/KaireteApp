import 'package:flutter/material.dart';
import 'package:kairete/features/forum/controllers/forum_controller.dart';
import 'package:get/get.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';
import 'package:cupertino_listview/cupertino_listview.dart';

// ignore: must_be_immutable
class ForumScreen extends StatelessWidget {
  ForumScreen({Key? key}) : super(key: key);
  ForumController controller = Get.put(ForumController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Forum',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          margin: const EdgeInsets.only(top: 4),
          child: GetX<ForumController>(
            builder: ((controller) {
              return controller.items.isEmpty
                  ? Container()
                  : CupertinoListView.builder(
                      sectionCount: controller.items.length,
                      sectionBuilder: (BuildContext context, SectionPath index,
                          bool isFloating) {
                        return Container(
                          color: kPrimaryColor,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            controller.items[index.section].title ?? '',
                            style: kTextHeadingStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      itemInSectionCount: (section) =>
                          controller.items[section].items?.length ?? 0,
                      childBuilder: (context, index) {
                        final item =
                            controller.items[index.section].items?[index.child];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 4),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  print(item);
                                  if (item != null) {
                                    controller.toDetail(item: item);
                                  }
                                },
                                child: Text(
                                  item?.title ?? '',
                                  style: kTextTitle.copyWith(fontSize: 18),
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Threads: ',
                                    style: kTextSubTitle.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    item?.typeData?.discussionCount
                                            .toString() ??
                                        '',
                                    style: kTextSubTitle.copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Messages: ',
                                    style: kTextSubTitle.copyWith(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    item?.typeData?.messageCount.toString() ??
                                        '',
                                    style: kTextSubTitle.copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                item?.typeData?.lastThreadTitle ?? 'None',
                                style: kTextTitle.copyWith(
                                  fontSize: 18,
                                  color: item?.typeData?.lastThreadTitle == null
                                      ? Colors.grey.shade600
                                      : kPrimaryColor,
                                ),
                              ),
                              if (item?.typeData?.lastPostDate != 0)
                                const SizedBox(
                                  height: 4,
                                ),
                              if (item?.typeData?.lastPostDate != 0)
                                Row(
                                  children: [
                                    Text(
                                      TimeManager.instance.getCalendar(
                                          timestamp:
                                              item?.typeData?.lastPostDate ??
                                                  0),
                                      style: kTextTitle.copyWith(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Text(' • '),
                                    Text(
                                      item?.typeData?.lastPostUsername ?? '',
                                      style: kTextTitle.copyWith(fontSize: 18),
                                    ),
                                  ],
                                )
                            ],
                          ),
                        );
                      },
                    );
            }),
          ),
        ),
      ),
    );
  }
}
