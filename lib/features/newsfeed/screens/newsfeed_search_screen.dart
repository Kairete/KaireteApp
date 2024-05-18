import 'dart:math';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:kairete/components/kairete_search_field.dart';
import 'package:kairete/constants/font_constant.dart';
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
          Obx(
            () => Row(
                children: controller.types
                    .map(
                      (element) => Expanded(
                        child: InkWell(
                          onTap: () {
                            controller.onChangeType(type: element);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  width: 1,
                                  color: kPrimaryColor,
                                ),
                                color: controller.selectedType.value == element
                                    ? kPrimaryColor
                                    : Colors.white),
                            child: Text(
                              element,
                              textAlign: TextAlign.center,
                              style: kTextMediumtStyle.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: controller.selectedType.value == element
                                    ? Colors.white
                                    : kPrimaryColor,
                              ),
                            ),
                            padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                            margin: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 8),
                          ),
                        ),
                      ),
                    )
                    .toList()),
            // children: [
            // SizedBox(
            //   width: 16,
            // ),
            // Obx(() => DropdownButton2(
            //       hint: Text(
            //         'Select Type',
            //         style: TextStyle(
            //           fontSize: 14,
            //           color: Theme.of(context).hintColor,
            //         ),
            //       ),
            //       items: controller.types
            //           .map((element) => DropdownMenuItem(
            //                 child: Text(element.toUpperCase()),
            //                 value: element,
            //               ))
            //           .toList(),
            //       value: controller.selectedType.value,
            //       onChanged: (value) {
            //         controller.onChangeType(type: value ?? 'all');
            //       },
            //       buttonStyleData: ButtonStyleData(
            //         padding: EdgeInsets.symmetric(horizontal: 16),
            //         height: 60,
            //         width: 150,
            //       ),
            //       menuItemStyleData: const MenuItemStyleData(
            //         height: 40,
            //       ),
            //     ))
            // ],
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
