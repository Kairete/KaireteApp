import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/components/cache_image.dart';
import 'package:kairete/components/kairete_bottom_sheet.dart';
import 'package:kairete/components/kairete_checkbox.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/color_constant.dart';
import 'package:kairete/constants/font_constant.dart';
import 'package:kairete/constants/size.dart';
import 'package:kairete/features/blogs/screens/my_blog_screen.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_detail_screen.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';
import 'package:kairete/features/profile/screens/user_profile_screen.dart';
import '../../../components/kairete_popup.dart';
import '../../../constants/app_routes.dart';
import '../../../routes/app_pages.dart';
import '../../login/models/user_model.dart';
import '../models/newsfeed_filter_model.dart';
import '../screens/create_newsfeed_screen.dart';
import '../screens/reply_screen.dart';

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
    await AuthMiddleware.instance.fetchStyle();
    final body = {};
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

  void toMyBlogs({BlogEntryItem? blog}) {
    Get.to(() => MyBlogScreen(), arguments: {'blog': blog});
  }

  Future onWatch({required NewsfeedModel item}) async {
    final blogId = item.blogEntryItem?.blogId;
    final json = await usecase.updateWatch(body: {'id': blogId});
    if (json != null) {}
  }

  void toTagDetail({required String id}) {
    print(id);
    Get.toNamed(Routes.tagsDetail, arguments: {'id': id});
  }

  void getReactionsList({required NewsfeedModel item}) async {
    final body = {
      'id': item.itemId,
    };
    final json = await usecase.getReactionsList(body: body);
    final data = NewsfeedModel.fromJson(json['newsfeedItem']);
    final items = data.reactionsList ?? [];
    Get.bottomSheet(
      Container(
        height: 400,
        child: ListView.separated(
          padding: EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KaireteCacheNetworkImage(
                    url: item.reactionUser?.avatarUrls?.h ?? '',
                    nameImage: item.reactionUser?.username,
                    width: 35,
                    height: 35,
                    isCircle: true,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.reactionUser?.username ?? '',
                              style: kTextTitle.copyWith(
                                fontSize: 16,
                                color: kTextDefaultColor,
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            KaireteCacheNetworkImage(
                              url: item.reaction?.imageUrl ?? '',
                              width: 17,
                              height: 17,
                            )
                          ],
                        ),
                        Text(
                          item.reactionUser?.userTitle ?? '',
                          style: kTextSubTitle.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: item.reactionUser?.getSubText() ?? '',
                            style: kTextRegularStyle.copyWith(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
          itemCount: items.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
