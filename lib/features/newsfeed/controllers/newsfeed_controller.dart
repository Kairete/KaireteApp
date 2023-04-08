import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_bottom_sheet.dart';
import 'package:kairete/components/kairete_checkbox.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_detail_screen.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';
import 'package:kairete/local/master_data.dart';
import '../../../components/kairete_popup.dart';
import '../models/newsfeed_filter_model.dart';
import '../screens/create_newsfeed_screen.dart';
import '../screens/reply_screen.dart';

class NewsFeedController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  BlogUsecase blogUsecase = IBlogUsecase();
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
  final sortItems = [
    NewsfeedFilterModel(title: 'Default'),
    NewsfeedFilterModel(title: 'Last comment date'),
    NewsfeedFilterModel(title: 'Popularity'),
  ];
  NewsfeedFilterModel? sortItemSelected;

  var selectedTabFilter = 99.obs;
  var onChangeFilter = false;
  var onChangeSort = false;

  @override
  void onInit() {
    fechItems();
    super.onInit();
  }

  void fechItems() async {
    final body = {
      // 'user_id': LocalManager.instance.read(key: PreferencesKey.token) ?? 0,
      // 'page': 1,
    };
    final json = await usecase.fetchItems(body: body);
    final item = BaseNewsfeedModel.fromJson(json);
    setFilterItem(items: item.filters ?? []);
    items.value = item.newsfeedItems ?? [];
    items.refresh();
  }

  void setFilterItem({required List<String> items}) {
    for (var element in items) {
      switch (element) {
        case 'own':
          filterItems
              .firstWhere((element) => element.title == 'Your content')
              .isSelected = true;
          break;
        case 'followed':
          filterItems
              .firstWhere((element) => element.title == 'Members you follow')
              .isSelected = true;
          break;
        case 'follower':
          filterItems
              .firstWhere((element) => element.title == 'Members follow you')
              .isSelected = true;
          break;
        case 'samegroup':
          filterItems
              .firstWhere(
                  (element) => element.title == 'Members in same groups')
              .isSelected = true;
          break;
        case 'friend':
          filterItems
              .firstWhere((element) => element.title == 'Your friends')
              .isSelected = true;
          break;
        case 'contain_keyword':
          filterItems
              .firstWhere(
                  (element) => element.title == 'Posts containing keywords')
              .isSelected = true;
          break;
        case 'watched_content':
          filterItems
              .firstWhere((element) => element.title == 'Watched content')
              .isSelected = true;
          break;
        case 'joined_groups':
          filterItems
              .firstWhere(
                  (element) => element.title == 'Posts from joined groups')
              .isSelected = true;
          break;
        case 'recent_popular':
          filterItems
              .firstWhere((element) => element.title == 'Recent popular posts')
              .isSelected = true;
          break;
        default:
      }
    }
  }

  void toDetail({required NewsfeedModel item}) {
    Get.to(() => NewsfeedDetailScreen(), arguments: {'item': item});
  }

  void toCreate() {
    Get.to(() => CreateNewsfeedScreen(), fullscreenDialog: true);
  }

  void resetFilter() {
    for (var element in filterItems) {
      element.isSelected = false;
    }
  }

  void resetSort() {
    for (var element in sortItems) {
      element.isSelected = false;
    }
  }

  void onSelectedTabFilter({required int index}) {
    if (index == selectedTabFilter.value) {
      return;
    }
    resetFilter();
    selectedTabFilter.value = index;
    switch (index) {
      case 0:
        for (var element in [filterItems[0], filterItems[1]]) {
          setFilterItems(title: element.title);
        }
        break;
      case 1:
        for (var element in [filterItems[0], filterItems[5], filterItems[6]]) {
          setFilterItems(title: element.title);
        }
        break;
      case 2:
        for (var element in [filterItems[1]]) {
          setFilterItems(title: element.title);
        }
        break;
      case 3:
        for (var element in [filterItems[3]]) {
          setFilterItems(title: element.title);
        }
        break;
      default:
        break;
    }
    filter();
  }

  void setFilterItems({required String title}) {
    filterItems.firstWhere((element) => element.title == title).isSelected =
        true;
  }

  void filter() async {
    Map<String, dynamic> body = {
      'own': filterItems
              .firstWhere((element) => element.title == 'Your content')
              .isSelected
          ? 1
          : null,
      'followed': filterItems
              .firstWhere((element) => element.title == 'Members you follow')
              .isSelected
          ? 1
          : null,
      'follower': filterItems
              .firstWhere((element) => element.title == 'Members follow you')
              .isSelected
          ? 1
          : null,
      'samegroup': filterItems
              .firstWhere(
                  (element) => element.title == 'Members in same groups')
              .isSelected
          ? 1
          : null,
      'friend': filterItems
              .firstWhere((element) => element.title == 'Your friends')
              .isSelected
          ? 1
          : null,
      'contain_keyword': filterItems
              .firstWhere(
                  (element) => element.title == 'Posts containing keywords')
              .isSelected
          ? 1
          : null,
      'watched_content': filterItems
              .firstWhere((element) => element.title == 'Watched content')
              .isSelected
          ? 1
          : null,
      'joined_groups': filterItems
              .firstWhere(
                  (element) => element.title == 'Posts from joined groups')
              .isSelected
          ? 1
          : null,
      'recent_popular': filterItems
              .firstWhere((element) => element.title == 'Recent popular posts')
              .isSelected
          ? 1
          : null,
    };
    if (sortItemSelected != null) {
      var order = '';
      switch (sortItemSelected!.title) {
        case 'Default':
          order = 'default';
          break;
        case 'Last comment date':
          order = 'last_comment_date';
          break;
        case 'Popularity':
          order = 'popularity';
          break;
        default:
          break;
      }
      body['order'] = order;
    }
    print(body);
    final json = await usecase.filter(body: body);
    if (json != null) {
      fechItems();
    }
  }

  void onSort() {
    onChangeSort = false;
    showKaireteBottomSheet(
        title: 'Order by',
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            kBottomSafea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: sortItems
                .map(
                  (e) => InkWell(
                    onTap: () {
                      onChangeSort = true;
                      Navigator.pop(Get.context!);
                      sortItemSelected = e;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: kPrimaryColor),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.title,
                              style: kTextRegularStyle.copyWith(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (e.title == sortItemSelected?.title)
                              const Icon(
                                Icons.check,
                                color: kPrimaryColor,
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        onComplete: () {
          if (onChangeSort) {
            filter();
          }
        });
  }

  void onFilter() {
    onChangeFilter = false;
    showKaireteBottomSheet(
        title: 'Filter',
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

  void onReactions({required int postId, required int reactionId}) async {
    final body = {
      'id': postId,
      'reaction_id': reactionId,
    };
    final json = await usecase.reactions(body: body);
    if (json['success'] == true) {
      fechItems();
    }
  }

  void onReactionsBlog({required int reactionId, required int blogId}) async {
    final body = {
      'id': blogId,
      'reaction_id': reactionId,
    };
    final json = await blogUsecase.reactions(body: body);
    if (json != null) {
      fechItems();
    }
  }

  void onComment() {}

  void showReactionPopup({required NewsfeedModel item}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(postId: item.itemId ?? 0, reactionId: reactionId);
      },
    );
  }

  void toReplies({required NewsfeedModel item}) {
    Get.to(() => ReplyScreen(), arguments: {'item': item});
  }

  void toProfile({User? user}) {
    if (user != null) {
      Get.to(
        () => UserProfileScreen(),
        arguments: {'id': user.userId},
      );
    }
  }
}
