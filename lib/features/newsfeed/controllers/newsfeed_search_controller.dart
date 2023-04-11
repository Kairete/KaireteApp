import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/newsfeed_detail_screen.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

class NewsfeedSearchController extends GetxController {
  NewsFeedUsecase usecase = INewsFeedUsecase();
  var items = <NewsfeedModel>[].obs;

  void onSearch({required String value}) async {
    if (value == '') {
      return;
    }
    final body = {'keywords': value};
    final json = await usecase.search(body: body);
    final item = BaseNewsfeedModel.fromJson(json);
    items.value = item.newsfeedItems ?? [];
    // items.removeWhere((element) => element.blogEntryItem?.category == null);
    items.refresh();
  }

  void toDetail({required NewsfeedModel item}) {
    Get.to(() => NewsfeedDetailScreen(), arguments: {
      'item': item,
    });
  }
}
