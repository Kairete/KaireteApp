import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hashtagable/functions.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/blogs/models/blog_cate_model.dart';
import 'package:kairete/features/blogs/models/blog_model.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/helper/user.dart';

import '../../../components/kairete_bottom_sheet.dart';
import '../../../components/kairete_checkbox.dart';
import '../../../constants/size.dart';
import '../usecase/blog_usecase.dart';

class BlogCreateController extends GetxController {
  var isEnable = false.obs;
  BlogUsecase usecase = IBlogUsecase();

  List<BlogCateModel> categories = [];
  List<BlogEntryItem> blogs = [];
  var selectedCategory = BlogCateModel().obs;
  var selectedBlog = BlogEntryItem().obs;

  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  var tags = '';

  @override
  void onInit() {
    fetchCate();
    fetchBlog();
    super.onInit();
  }

  void fetchCate() async {
    final json = await usecase.fetchItemsFromCate();
    categories = json['categories']
        .map<BlogCateModel>((e) => BlogCateModel.fromJson(e))
        .toList();
  }

  void fetchBlog() async {
    final body = {'creator_id': UserManager.instance.userId};
    final json = await usecase.myBlogs(body: body);
    final item = BlogModel.fromJson(json);
    blogs = item.blogEntryItems ?? [];
    final dataDefault = BlogEntryItem(
      blogId: 0,
      title: 'Create new blog',
    );
    blogs.insert(0, dataDefault);
  }

  void showCategory() async {
    showKaireteBottomSheet(
        title: 'Categories',
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            kBottomSafea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: categories
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KaireteCheckBox(
                      title: e.title,
                      value: e.categoryId == selectedCategory.value.categoryId,
                      onChanged: (value) {
                        selectedCategory.value =
                            value == true ? e : BlogCateModel();
                        Get.back();
                        checkData();
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        onComplete: () {
          // if (onChangeFilter) {
          //   filter();
          // }
        });
  }

  void showBlogs() async {
    showKaireteBottomSheet(
        title: 'Categories',
        customContent: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            kBottomSafea,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: blogs
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: KaireteCheckBox(
                      title: e.title,
                      value: e.blogId == selectedBlog.value.blogId,
                      onChanged: (value) {
                        selectedBlog.value =
                            value == true ? e : BlogEntryItem();
                        Get.back();
                        checkData();
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        onComplete: () {
          // if (onChangeFilter) {
          //   filter();
          // }
        });
  }

  void createBlog() async {
    final tag =
        extractHashTags(tags).map((e) => e.replaceAll('#', '')).toList();
    final body = {
      'category_id': selectedCategory.value.categoryId,
      'blog_id': selectedBlog.value.blogId,
      'message': messageController.text,
      'title': titleController.text,
      'user_id': UserManager.instance.userId,
      'tags[]': tag,
    };
    print(body);
    final json = await usecase.createBlog(body: body);
    if (json != null) {
      showKairetePopup(
        onTapDone: () {},
        content: 'Create blog success',
      );
    }
  }

  void checkData() {
    isEnable.value = selectedBlog.value.blogId != null &&
        selectedCategory.value.categoryId != null &&
        titleController.text.isNotEmpty &&
        messageController.text.isNotEmpty;
  }
}
