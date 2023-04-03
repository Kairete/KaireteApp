import 'package:get/get.dart';
import 'package:kairete/features/forum/models/forum_model.dart';
import 'package:kairete/features/forum/screens/forum_detail_screen.dart';
import 'package:kairete/features/forum/usecase/forum_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../models/forum_detail_model.dart';

class ForumController extends GetxController {
  ForumUsecase usecase = IForumUsecase();

  var items = <GroupNodes>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
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
