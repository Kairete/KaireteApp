import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_search_field.dart';
import 'package:kairete/features/newsfeed/controllers/newsfeed_search_controller.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_screen.dart';

import '../../../constants/color.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class NewsfeedSearchScreen extends GetView {
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
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
              ),
              Obx(() => DropdownButton2(
                    hint: Text(
                      'Select Type',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: controller.types
                        .map((element) => DropdownMenuItem(
                              child: Text(element.toUpperCase()),
                              value: element,
                            ))
                        .toList(),
                    value: controller.selectedType.value,
                    onChanged: (value) {
                      controller.onChangeType(type: value ?? 'all');
                    },
                    buttonStyleData: ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 60,
                      width: 150,
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                    ),
                  ))
            ],
          ),
          Expanded(
            child: Obx(() => controller.items.isEmpty
                ? const SizedBox()
                : NewsfeedListItem(
                    items: controller.items,
                    isShowCreate: false,
                    onTapDetail: (item) {
                      controller.toDetail(item: item);
                    },
                  )),
          ),
        ],
      ),
    );
  }
}
