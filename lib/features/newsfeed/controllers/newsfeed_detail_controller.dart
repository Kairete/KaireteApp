import 'package:get/get.dart';

import '../models/newsfeed_model.dart';

class NewsfeedDetailController extends GetxController {
  NewsfeedModel? item;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
  }
}
