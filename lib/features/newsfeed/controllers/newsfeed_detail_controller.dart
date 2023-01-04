import 'package:get/get.dart';

import '../../blogs/screens/blog_filter_screen.dart';
import '../models/newsfeed_model.dart';

class NewsfeedDetailController extends GetxController {
  NewsfeedModel? item;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
  }

  void toCate() {
    Get.to(() => BlogFilterScreen(),
        arguments: {'category': item?.blogEntryItem?.category});
  }
}
