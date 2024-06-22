import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/articles/screens/articles_category_screen.dart';
import 'package:kairete/features/articles/usecase/articles_usecase.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/reply_screen.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../models/articles_model.dart';

class ArticlesDetailController extends GetxController {
  var item = ArticleItems().obs;
  var newfeed = NewsfeedModel().obs;
  ArticlesUsecase usecase = IArticlesUsecase();
  NewsFeedUsecase newFeedUsecase = INewsFeedUsecase();
  List<ArticleItems> dataStack = [];

  @override
  void onInit() {
    fetchItem();
    super.onInit();
  }

  void fetchItem() async {
    final data = Get.arguments['item'];
    final body = {'id': data.articleId?.toString()};
    final json = await usecase.fetItem(body: body);
    final item = ArticleItems.fromJson(json['article']);
    fetchNewfeedItem(id: item.newfeedId ?? 0);
    dataStack.add(item);
    this.item.value = dataStack.last;
  }

  void removeStack() {
    if (dataStack.isNotEmpty) {
      dataStack.removeLast();
    }
  }

  void updateOriginData() {
    item.value = dataStack.first;
  }

  void fetchNewfeedItem({required int id}) async {
    final json = await usecase.fetchNewfeedItem(id: id);
    newfeed.value = NewsfeedModel.fromJson(json['newsfeedItem']);
  }

  void onReactions({required int postId, required int reactionId}) async {
    final body = {
      'id': postId,
      'reaction_id': reactionId,
    };
    final json = await newFeedUsecase.reactions(body: body);
    if (json['success'] == true) {
      fetchNewfeedItem(id: item.value.newfeedId ?? 0);
    }
  }

  void showReactionPopup() {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(postId: newfeed.value.itemId ?? 0, reactionId: reactionId);
      },
    );
  }

  void toReplies() {
    Get.to(() => ReplyScreen(), arguments: {'item': newfeed.value});
  }

  void toCategory() {
    Get.to(() => AritclesCategoryScreen(), arguments: {
      'id': item.value.category?.categoryId,
    });
  }
}
