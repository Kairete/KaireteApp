import 'package:get/get.dart';

import '../models/articles_model.dart';

class ArticlesDetailController extends GetxController {
  ArticleItems? item;

  @override
  void onInit() {
    item = Get.arguments['item'];
    super.onInit();
  }
}
