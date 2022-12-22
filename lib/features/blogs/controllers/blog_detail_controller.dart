import 'package:get/get.dart';

import '../../newsfeed/models/newsfeed_model.dart';

class BlogsDetailController extends GetxController {
  BlogEntryItem? item;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
  }
}
