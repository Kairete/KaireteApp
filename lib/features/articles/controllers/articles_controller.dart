import 'package:get/get.dart';
import 'package:kairete/features/articles/models/articles_model.dart';
import 'package:kairete/features/articles/screens/articles_detail_screen.dart';
import 'package:kairete/features/articles/usecase/articles_usecase.dart';

import '../../../constants/app_routes.dart';

List<ArticleItems> cacheArticle = [];

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

  void fetchItems({bool isRefresh = false}) async {
    if (cacheArticle.isNotEmpty && !isRefresh) {
      items.value = cacheArticle;
      items.removeWhere((element) => element.coverImage == null);
      items.refresh();
      return;
    }
    final json = await usecase.fetItems();
    final item = ArticlesModel.fromJson(json);
    cacheArticle = item.articleItems ?? [];
    items.value = item.articleItems ?? [];

    items.removeWhere((element) => element.coverImage == null);
    items.refresh();
  }

  void toDetail({required ArticleItems item}) {
    Get.to(() => ArticlesDetailScreen(), arguments: {'item': item});
  }

  Future updateWatch({required ArticleItems item}) async {
    final json =
        await usecase.updateWatch(body: {'id': item.articleId.toString()});
    if (json != null) {
      items
          .firstWhere((element) => element.articleId == item.articleId)
          .isWatched = !(item.isWatched ?? false);
      items.refresh();
    }
  }

  void toTagDetail({required String id}) {
    Get.toNamed(Routes.tagsDetail, arguments: {'id': id});
  }
}
