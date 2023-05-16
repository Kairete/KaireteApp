import 'package:get/get.dart';
import 'package:kairete/features/groups/models/group_model/group.dart';
import 'package:kairete/features/groups/models/group_model/group_model.dart';
import 'package:kairete/features/groups/usecase/group_usecase.dart';

class GroupController extends GetxController {
  GroupUsecase usecase = IGroupUsecase();

  var items = <Group>[].obs;

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetchItems();
    items.value = GroupModel.fromJson(json).groups ?? [];
  }
}
