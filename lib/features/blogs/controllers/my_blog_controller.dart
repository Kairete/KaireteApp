import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';

import '../models/blog_model.dart';

class MyBlogController extends BlogController {
  BlogEntryItem? blog;

  @override
  void onInit() {
    blog = Get.arguments['blog'];
    fetchItems();
    super.onInit();
  }

  @override
  void fetchItems() async {
    final body = {
      'blog_ids[]': blog?.blog?.blogId,
    };
    final json = await usecase.fetItems(body: body);
    final item = BlogModel.fromJson(json);
    items.value = item.blogEntryItems ?? [];
  }
}
