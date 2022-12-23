import 'package:get/get.dart';

import '../models/newsfeed_model.dart';

class NewsfeedDetailController extends GetxController {
  NewsfeedModel? item;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
    print(item?.blogEntryItem?.messageParsed);
    final a = item?.blogEntryItem?.messageParsed
        ?.replaceAll("\n", "")
        .replaceAll("=\\  ", "=")
        .replaceAll("g\\", "");
    print(a);
  }
}
