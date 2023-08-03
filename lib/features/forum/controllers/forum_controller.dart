import 'package:get/get.dart';
import 'package:kairete/features/forum/models/forum_model.dart';
import 'package:kairete/features/forum/models/forum_static_model/latest_user.dart';
import 'package:kairete/features/forum/screens/forum_detail_screen.dart';
import 'package:kairete/features/forum/usecase/forum_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../dashboard/usecase/master_data_usecase.dart';
import '../../profile/screens/user_profile_screen.dart';
import '../models/forum_detail_model.dart';
import '../models/forum_static_model/forum_static_model.dart';

class ForumController extends GetxController {
  ForumUsecase usecase = IForumUsecase();

  var items = <GroupNodes>[].obs;
  var static = ForumStaticModel().obs;
  MasterDataUsecase masterDataUsecase = IMasterDataUsecase();

  @override
  void onInit() {
    fetchWidget();
    super.onInit();
  }

  void fetchWidget() async {
    final params = {'widget_key': 'forum_overview_forum_statistics'};
    final json = await masterDataUsecase.fetchWidget(body: params);
    static.value = ForumStaticModel.fromJson(json[0]['forumStatistics']);
    fetchItems();
  }

  void toProfile({LatestUser? user}) {
    if (user != null) {
      Get.to(
        () => UserProfileScreen(),
        arguments: {'id': user.userId},
      );
    }
  }

  void fetchItems() async {
    final json = await usecase.nodeList();
    final data = ForumModel.fromJson(json).nodes ?? [];
    // final groups = data.groupBy(
    //   (element) => element.parentNodeId,
    //   valueTransform: (element) => element,
    // );

    for (var element in data) {
      if (element.nodeTypeId == 'Category') {
        final e =
            GroupNodes(items: [], title: element.title, id: element.nodeId);
        items.add(e);
      }
    }

    for (var element in data) {
      items
          .firstWhereOrNull((e) => e.id == element.parentNodeId)
          ?.items
          ?.add(element);
    }
    items.refresh();
  }

  void toDetail({required Nodes item}) {
    Get.to(() => ForumDetailScreen(), arguments: {'item': item});
  }
}
