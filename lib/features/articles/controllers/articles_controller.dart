import 'package:get/get.dart';
import 'package:kairete/features/articles/models/articles_model.dart';
import 'package:kairete/features/articles/screens/articles_detail_screen.dart';
import 'package:kairete/features/articles/usecase/articles_usecase.dart';

class ArticlesController extends GetxController {
  ArticlesUsecase usecase = IArticlesUsecase();
  var items = <ArticleItems>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    fetchItems();
    super.onReady();
  }

  void fetchItems() async {
    final json = await usecase.fetItems();
    final item = ArticlesModel.fromJson(json);
    items.value = item.articleItems ?? [];
    items.removeWhere((element) => element.coverImage == null);
    items.refresh();
  }

  void toDetail({required ArticleItems item}) {
    Get.to(() => ArticlesDetailScreen(), arguments: {'item': item});
  }
}
