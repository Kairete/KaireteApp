import 'package:get/get.dart';
import 'package:kairete/features/blogs/usecase/blog_usecase.dart';
import 'package:kairete/features/tags/usecase/tags_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../blogs/screens/blog_comment_screen.dart';
import '../../blogs/screens/blog_detail_screen.dart';
import '../../newsfeed/models/newsfeed_model.dart';

class TagsController extends GetxController {
  final useCase = ITagsUsecaseUsecase();
  final blogUsecase = IBlogUsecase();
  var items = <BlogEntryItem>[].obs;
  String? id;

  @override
  void onInit() {
    super.onInit();
    id = Get.arguments["id"];
    if (id != null) {
      fetchItems();
    }
  }

  void showReactions({required int blogId}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReaction(
          reactionId: reactionId,
          blogId: blogId,
        );
      },
    );
  }

  void onReaction({required int reactionId, required int blogId}) async {
    final body = {
      'id': blogId,
      'reaction_id': reactionId,
    };
    final json = await blogUsecase.reactions(body: body);
    if (json != null) {
      fetchItems();
    }
  }

  void toComment({required BlogEntryItem item}) {
    Get.to(() => BlogCommentScreen(), arguments: {
      'item': item,
    });
  }

  void fetchItems() async {
    final json = await useCase.fetchItems(id: id ?? '');
    final results = json['results'];
    final keys = results.keys;
    keys.forEach((element) {
      final json = results[element]['BlogEntryItem'];
      if (json != null) {
        final item = BlogEntryItem.fromJson(json);
        items.add(item);
      }
    });
    items.refresh();
    print(items.length);
  }

  void toDetail({required BlogEntryItem item}) {
    Get.to(() => BlogDetailScreen(), arguments: {'item': item});
  }
}
