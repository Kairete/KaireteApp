import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_detail_screen.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_search_screen.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../helper/user.dart';
import '../screens/create_newsfeed_screen.dart';

class NewsFeedController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  var items = <NewsfeedModel>[].obs;

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

  void onFilter() {
    print('a');
  }
}
