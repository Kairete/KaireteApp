import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/kairete_bottom_sheet.dart';
import 'package:kairete/components/kairete_checkbox.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_detail_screen.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../helper/user.dart';
import '../models/newsfeed_filter_model.dart';
import '../screens/create_newsfeed_screen.dart';

class NewsFeedController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  var items = <NewsfeedModel>[].obs;
  final filterItems = [
    NewsfeedFilterModel(title: 'Your content'),
    NewsfeedFilterModel(title: 'Members you follow'),
    NewsfeedFilterModel(title: 'Members follow you'),
    NewsfeedFilterModel(title: 'Members in same groups'),
    NewsfeedFilterModel(title: 'Your friends'),
    NewsfeedFilterModel(title: 'Posts containing keywords'),
    NewsfeedFilterModel(title: 'Watched content'),
    NewsfeedFilterModel(title: 'Posts from joined groups'),
    NewsfeedFilterModel(title: 'Recent popular posts'),
  ];

  var selectedTabFilter = 99.obs;
  var onChangeFilter = false;

  @override
  void onInit() {
    fechItems();
    super.onInit();
  }

  void fechItems() async {
    final body = {
      'user_id': UserManager.instance.user?.user?.userId ?? 0,
      'page': 1,
    };
    final json = await usecase.fetchItems(body: body);
    final item = BaseNewsfeedModel.fromJson(json);
    items.value = item.newsfeedItems ?? [];
    items.refresh();
  }

  void toDetail({required NewsfeedModel item}) {
    Get.to(() => NewsfeedDetailScreen(), arguments: {'item': item});
  }

  void toCreate() {
    Get.to(() => CreateNewsfeedScreen(), fullscreenDialog: true);
  }

  void resetFilter() {
    filterItems.forEach((element) {
      element.isSelected = false;
    });
  }

  void onSelectedTabFilter({required int index}) {
    if (index == selectedTabFilter.value) {
      return;
    }
    resetFilter();
    selectedTabFilter.value = index;
    switch (index) {
      case 0:
        [filterItems[0], filterItems[1]].forEach((element) {
          setFilterItems(title: element.title);
        });
        break;
      case 1:
        [filterItems[0], filterItems[5], filterItems[6]].forEach((element) {
          setFilterItems(title: element.title);
        });
        break;
      case 2:
        [filterItems[1]].forEach((element) {
          setFilterItems(title: element.title);
        });
        break;
      case 3:
        [filterItems[3]].forEach((element) {
          setFilterItems(title: element.title);
        });
        break;
      default:
        break;
    }
    fechItems();
  }

  void setFilterItems({required String title}) {
    filterItems.firstWhere((element) => element.title == title).isSelected =
        true;
  }

  void filter() async {
    final body = {
      'user_id': UserManager.instance.user?.user?.userId,
      'own': filterItems
          .firstWhere((element) => element.title == 'Your content')
          .isSelected,
      'followed': filterItems
          .firstWhere((element) => element.title == 'Members you follow')
          .isSelected,
      'follower': filterItems
          .firstWhere((element) => element.title == 'Members follow you')
          .isSelected,
      'samegroup': filterItems
          .firstWhere((element) => element.title == 'Members in same groups')
          .isSelected,
      'friend': filterItems
          .firstWhere((element) => element.title == 'Your friends')
          .isSelected,
      'contain_keyword': filterItems
          .firstWhere((element) => element.title == 'Posts containing keywords')
          .isSelected,
      'watched_content': filterItems
          .firstWhere((element) => element.title == 'Watched content')
          .isSelected,
      'joined_groups': filterItems
          .firstWhere((element) => element.title == 'Posts from joined groups')
          .isSelected,
      'recent_popular': filterItems
          .firstWhere((element) => element.title == 'Recent popular posts')
          .isSelected,
    };
    final json = await usecase.filter(body: body);
    if (json != null) {
      fechItems();
    }
  }

  void onFilter() {
    onChangeFilter = false;
    showKaireteBottomSheet(
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            kBottomSafea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: filterItems
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KaireteCheckBox(
                      title: e.title,
                      value: e.isSelected,
                      onChanged: (value) {
                        onChangeFilter = true;
                        selectedTabFilter.value = 99;
                        filterItems
                            .firstWhere((element) => element.title == e.title)
                            .isSelected = value ?? false;
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        onComplete: () {
          if (onChangeFilter) {
            filter();
          }
        });
  }
}
