import 'dart:developer';

import 'package:get/get.dart';
import 'package:kairete/features/blogs/controllers/blog_controller.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';

import '../models/blog_model.dart';

class MyBlogController extends BlogController {
  BlogEntryItem? blog;
  BlogUsecase usecase = IBlogUsecase();
  var isWatchedForum = false.obs;

  @override
  void onInit() {
    blog = Get.arguments['blog'];
    fetchMyBlog();
    fetchItems();
    super.onInit();
  }

  void fetchMyBlog() async {
    final body = {
      'id': blog?.blog?.blogId.toString(),
    };
    final json = await usecase.myBlog(body: body);
    final item = BlogEntryItem.fromJson(json['blog']);
    isWatchedForum.value = item.isWatched ?? false;
  }

  @override
  void fetchItems({bool isRefresh = false}) async {
    final body = {
      'blog_ids[]': blog?.blog?.blogId,
    };
    final json = await usecase.fetItems(body: body);
    final item = BlogModel.fromJson(json);
    items.value = item.blogEntryItems ?? [];
    print(items.length);
  }

  void updateWatch() async {
    final json = await usecase.updateWatchBlogs(body: {
      'id': blog?.blog?.blogId,
    });
    if (json != null) {
      fetchMyBlog();
    }
  }
}
