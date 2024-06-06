import 'package:get/get.dart';
import 'package:kairete/features/reactions/reaction_model/reaction_user.dart';
import 'package:kairete/features/settings/activity/activity_usecase.dart';

class ActivityController extends GetxController {
  var htmlData = ''.obs;
  ActivityUsecase usecase = IActivityUsecase();

  ActivityType type = ActivityType.follower;
  var items = <ReactionUser>[].obs;

  @override
  void onInit() {
    if (Get.arguments['type'] != null) {
      type = Get.arguments['type'];
    }
    super.onInit();
    fetchItems();
  }

  void fetchItems() async {
    var data;
    switch (type) {
      case ActivityType.follower:
        final json = await usecase.follower();
        data = json['followers'];
        break;
      case ActivityType.following:
        final json = await usecase.following();
        data = json['followings'];
        break;
      case ActivityType.bookmark:
        final json = await usecase.bookmark();
        data = json['bookmarks'];
        break;
      default:
    }
    items.value =
        data.map<ReactionUser>((e) => ReactionUser.fromJson(e)).toList();
  }
}

enum ActivityType {
  follower,
  following,
  bookmark,
}
