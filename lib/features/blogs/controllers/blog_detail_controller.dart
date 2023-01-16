import 'package:get/get.dart';

import '../../newsfeed/models/newsfeed_model.dart';
import '../screens/blog_filter_screen.dart';

class BlogsDetailController extends GetxController {
  BlogEntryItem? item;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
  }

  void toCate() {
    Get.to(() => BlogFilterScreen(), arguments: {'category': item?.category});
  }

  void toFilterWithTitle() {
    Get.to(() => BlogFilterScreen(), arguments: {
      'blogId': item?.blog?.blogId,
    });
  }
}
