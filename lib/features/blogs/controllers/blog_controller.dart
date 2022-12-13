import 'package:get/get.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';
import '../models/blog_model.dart';

class BlogController extends GetxController {
  BlogUsecase usecase = IBlogUsecase();
  var items = <BlogEntryItems>[].obs;

  @override
  void onInit() {
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    final json = await usecase.fetItems();
    final item = BlogModel.fromJson(json);
    items.value = item.blogEntryItems ?? [];
  }
}
