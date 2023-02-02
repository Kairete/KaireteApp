import 'package:get/get.dart';
import 'package:kairete/features/forum/models/forum_model.dart';
import 'package:kairete/features/forum/screens/forum_detail_screen.dart';
import 'package:kairete/features/forum/usecase/forum_usecase.dart';

class ForumController extends GetxController {
  ForumUsecase usecase = IForumUsecase();

  var items = <Nodes>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  void fetchItems() async {
    final json = await usecase.nodeList();
    items.value = ForumModel.fromJson(json).nodes ?? [];
  }

  void toDetail({required Nodes item}) {
    Get.to(() => ForumDetailScreen(), arguments: {'item': item});
  }
}
