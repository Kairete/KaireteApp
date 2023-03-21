import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

class ReplyController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  @override
  void onInit() {
    int? id = Get.arguments['id'];
    fetchItems(id: id);
    super.onInit();
  }

  void fetchItems({int? id}) async {
    final body = {'id': id};
    final json = await usecase.comments(body: body);
  }
}
