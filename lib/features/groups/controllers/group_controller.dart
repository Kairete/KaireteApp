import 'package:get/get.dart';
import 'package:kairete/features/groups/screens/group_feed_screen.dart';
import 'package:kairete/features/groups/screens/newfeed_group_screen.dart';
import 'package:kairete/features/groups/usecase/group_usecase.dart';

import '../model/group.dart';
import '../model/model.dart';

class GroupController extends GetxController {
  GroupUsecase usecase = IGroupUsecase();

  var items = <Group>[].obs;
  Group? currentGroup;

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetchItems();
    items.value = GroupModel.fromJson(json).groups ?? [];
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
      Get.to(() => GroupFeedScreen(), arguments: {'groupId': item.groupId});
    }
    currentGroup = item;
  }
}
