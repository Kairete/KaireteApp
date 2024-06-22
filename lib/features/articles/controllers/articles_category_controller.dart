import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/features/articles/controllers/articles_controller.dart';
import 'package:kairete/features/articles/controllers/articles_detail_controller.dart';
import 'package:kairete/features/articles/models/articles_model.dart';

class ArticlesCategoryController extends ArticlesController {
  int? categoryId;

  @override
  void onInit() {
    if (Get.arguments['id'] != null) {
      categoryId = Get.arguments['id'];
    }
    super.onInit();
  }

  @override
  void fetchItems({bool isRefresh = false}) async {
    final body = {
      'category_ids[]': categoryId,
    };
    final json = await usecase.fetItems(body: body);
    final item = ArticlesModel.fromJson(json);
    items.value = item.articleItems ?? [];

    items.removeWhere((element) => element.coverImage == null);
    items.refresh();
  }

  @override
  void toDetail({required ArticleItems item}) {
    print('aaa');
    Get.toNamed(
      Routes.articlesCate,
      arguments: {'item': item},
    );
    Get.find<ArticlesDetailController>().fetchItem();
  }
}
