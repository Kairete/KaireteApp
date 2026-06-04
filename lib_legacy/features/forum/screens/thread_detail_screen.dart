import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:kairete/features/forum/controllers/thread_detail_controller.dart';

import '../../../constants/color.dart';
import '../../../constants/font_constant.dart';
import 'forum_detail_screen.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class ThreadDetailScreen extends StatelessWidget {
  ThreadDetailScreen({Key? key}) : super(key: key);

  ThreadDetailController controller = Get.put(ThreadDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Thread detail',
          style: kTextHeadingStyle.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Obx(() => controller.item.value.message == null
            ? SizedBox()
            : Container(
                color: Colors.grey.shade200,
                child: ThreadItemCell(
                  item: controller.item.value,
                  onTapComment: () {
                    controller.toComment();
                  },
                  onTapReactions: () {
                    controller.showReactionPopup();
                  },
                  isShowDetail: false,
                ))),
      ),
    );
  }
}
