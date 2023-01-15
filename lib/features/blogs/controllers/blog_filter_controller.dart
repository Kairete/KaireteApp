import 'package:get/get.dart';
import 'package:kairete/features/blogs/screens/blog_detail_screen.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';

import '../../newsfeed/models/newsfeed_model.dart';
import '../models/blog_model.dart';

class BlogFilterController extends GetxController {
  BlogUsecase usecase = IBlogUsecase();
  Category? cate;
  String? title;
  var items = <BlogEntryItem>[].obs;

  @override
  void onInit() {
    if (Get.arguments != null) {
      if (Get.arguments['title'] != null) {
        title = Get.arguments['title'];
      }
      if (Get.arguments['category'] != null) {
        cate = Get.arguments['category'];
      }
    }
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    Map<String, dynamic> body = {};
    if (title != null) {
      body['title'] = title;
    }
    if (cate != null) {
      body['category_ids[]'] = cate?.categoryId;
    }
    print(body);
    final json = await usecase.fetchItemsFromCate(body: body);
    final item = BlogModel.fromJson(json);
    items.value = item.blogEntryItems ?? [];
  }

  void toDetail({required BlogEntryItem item}) {
    Get.to(() => BlogDetailScreen(), arguments: {'item': item});
  }
}
