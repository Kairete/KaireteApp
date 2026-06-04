import 'package:flutter/material.dart';
import 'package:kairete/features/dashboard/screens/dashboard_screen.dart';
import 'package:kairete/features/forum/controllers/forum_controller.dart';
import 'package:get/get.dart';
import '../../../constants/color.dart';
import '../../../theme/kairete_theme.dart';
import '../../../constants/font_constant.dart';
import '../../../helper/time.dart';
import 'package:cupertino_listview/cupertino_listview.dart';

// ignore: must_be_immutable
class ForumScreen extends StatelessWidget {
  ForumScreen({Key? key}) : super(key: key);
  ForumController controller = Get.put(ForumController());
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: baseAppBar(key: _key, isShowBack: true),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade200,
          margin: const EdgeInsets.only(top: 4),
          child: GetX<ForumController>(
            builder: ((controller) {
              return controller.items.isEmpty
                  ? Container()
                  : CupertinoListView.builder(
                      sectionCount: controller.items.length + 1,
                      sectionBuilder: (BuildContext context, SectionPath index,
                          bool isFloating) {
                        String? title = index.section < controller.items.length
                            ? controller.items[index.section].title
                            : 'Forum statistics';
                        return Container(
                          color: KaireteTheme.sectionHeaderBackground,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            title ?? '',
                            style: kTextHeadingStyle.copyWith(
                                color: KaireteTheme.textPrimary,
                                fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      itemInSectionCount: (section) {
                        if (section < controller.items.length) {
                          return controller.items[section].items?.length ?? 0;
                        } else {
                          return 1;
                        }
                      },
                      childBuilder: (context, index) {
                        if (index.section < controller.items.length) {
                          final item = controller
                              .items[index.section].items?[index.child];
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
                                      style:
                                          kTextSubTitle.copyWith(fontSize: 16),
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
                                      style:
                                          kTextSubTitle.copyWith(fontSize: 16),
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
                                    color:
                                        item?.typeData?.lastThreadTitle == null
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
                                        style:
                                            kTextTitle.copyWith(fontSize: 18),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          );
                        } else {
                          final item = controller.static.value;
                          return Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Threads: ',
                                      style: kTextSubTitle.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      item.threads.toString(),
                                      style: kTextSubTitle.copyWith(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Messages: ',
                                      style: kTextSubTitle.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      item.messages.toString(),
                                      style: kTextSubTitle.copyWith(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Members: ',
                                      style: kTextSubTitle.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      item.users.toString(),
                                      style: kTextSubTitle.copyWith(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.toProfile(user: item.latestUser);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Last member: ',
                                        style: kTextSubTitle.copyWith(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        item.latestUser?.username ?? '',
                                        style: kTextSubTitle.copyWith(
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }
                      },
                    );
            }),
          ),
        ),
      ),
    );
  }
}
