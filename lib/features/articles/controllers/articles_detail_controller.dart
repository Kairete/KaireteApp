import 'package:get/get.dart';
import 'package:kairete/features/articles/usecase/articles_usecase.dart';

import '../models/articles_model.dart';

class ArticlesDetailController extends GetxController {
  var item = ArticleItems().obs;
  ArticlesUsecase usecase = IArticlesUsecase();

  @override
  void onInit() {
    fetchItem();
    super.onInit();
  }

  void fetchItem() async {
    final data = Get.arguments['item'];
    final body = {'id': data.articleId?.toString()};
    final json = await usecase.fetItem(body: body);
    item.value = ArticleItems.fromJson(json['article']);
  }
}
