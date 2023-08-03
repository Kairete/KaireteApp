import 'package:get/get.dart';
import 'package:kairete/features/dashboard/usecase/master_data_usecase.dart';
import 'package:kairete/features/groups/screens/group_feed_screen.dart';
import 'package:kairete/features/groups/screens/newfeed_group_screen.dart';
import 'package:kairete/features/groups/usecase/group_usecase.dart';

import '../model/group.dart';
import '../model/model.dart';

class GroupController extends GetxController {
  GroupUsecase usecase = IGroupUsecase();
  MasterDataUsecase masterDataUsecase = IMasterDataUsecase();

  var items = <Group>[].obs;
  var recents = <Group>[].obs;
  var mosts = <Group>[].obs;
  Group? currentGroup;

  @override
  void onInit() {
    fetchItems();
    fetchWidgetRecent();
    fetchWidgetMost();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetchItems();
    items.value = GroupModel.fromJson(json).groups ?? [];
  }

  void fetchWidgetRecent() async {
    final body = {'widget_key': 'tlg_groups_recent'};
    final json = await masterDataUsecase.fetchWidget(body: body);
    recents.value = GroupModel.fromJson(json[0]).groups ?? [];
  }

  void fetchWidgetMost() async {
    final body = {'widget_key': 'tlg_groups_mostViewed'};
    final json = await masterDataUsecase.fetchWidget(body: body);
    mosts.value = GroupModel.fromJson(json[0]).groups ?? [];
  }

  void groupActions({required Group item}) async {
    final body = {'id': item.groupId};
    if (item.isJoined ?? false) {
      final json = await usecase.leave(body: body);
      if (json != null) {
        fetchItems();
      }
    } else {
      final json = await usecase.join(body: body);
      if (json != null) {
        fetchItems();
      }
    }
  }

  void toDetail({required Group item}) {
    if (item.isNewsfeedGroup ?? false) {
      Get.to(() => NewfeedGroupScreen(), arguments: {'groupId': item.groupId});
    } else {
      Get.to(() => GroupFeedScreen(), arguments: {
        'groupId': item.groupId,
        'postId': item.postId,
      });
    }
    currentGroup = item;
  }
}
