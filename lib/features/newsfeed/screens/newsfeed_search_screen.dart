import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_search_field.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_search_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

import '../../../constants/color.dart';
import 'package:get/get.dart';

class NewsfeedSearchScreen extends StatelessWidget {
  NewsfeedSearchScreen({Key? key}) : super(key: key);

  NewsfeedSearchController controller = Get.put(NewsfeedSearchController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: SizedBox(
          child: KaireteSearchField(
            onChanged: (value) {},
            onSubmitted: (value) {
              controller.onSearch(value: value);
            },
          ),
          height: 36,
        ),
      ),
      body: Obx(() => controller.items.isEmpty
          ? SizedBox()
          : NewsfeedListItem(
              items: controller.items.value,
              isShowCreate: false,
              onTapDetail: (item) {
                controller.toDetail(item: item);
              },
            )),
    );
  }
}
