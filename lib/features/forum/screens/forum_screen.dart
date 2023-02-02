import 'package:flutter/material.dart';
import 'package:kairete/features/forum/controllers/forum_controller.dart';
import 'package:get/get.dart';
import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';

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
          child: Obx(() => ListView.builder(
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.toDetail(item: item);
                          },
                          child: Text(
                            item.title ?? '',
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
                                  color: Colors.grey.shade600, fontSize: 16),
                            ),
                            Text(
                              item.typeData?.discussionCount.toString() ?? '',
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
                              item.typeData?.messageCount.toString() ?? '',
                              style: kTextSubTitle.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Text(
                              item.typeData?.lastThreadTitle ?? '',
                              style: kTextTitle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              TimeManager.instance.convertFromTimeStamp(
                                  timestamp: item.typeData?.lastPostDate ?? 0,
                                  format: 'MMM do, yyyy'),
                              style: kTextTitle.copyWith(
                                  fontSize: 16, color: Colors.grey.shade600),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              item.typeData?.lastPostUsername ?? '',
                              style: kTextTitle.copyWith(fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              )),
        ),
      ),
    );
  }
}
