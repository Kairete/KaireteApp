import 'package:get/get.dart';
import 'package:kairete/features/blogs/screens/blog_detail_screen.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../models/blog_model.dart';

class BlogController extends GetxController {
  BlogUsecase usecase = IBlogUsecase();
  var items = <BlogEntryItem>[].obs;

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

  void toDetail({required BlogEntryItem item}) {
    Get.to(() => BlogDetailScreen(), arguments: {'item': item});
  }
}
