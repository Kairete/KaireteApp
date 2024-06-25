import 'package:get/get.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/articles/usecase/articles_usecase.dart';
import 'package:kairete/features/media/models/media_model.dart';
import 'package:kairete/features/media/usecase/media_uscase.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';
import 'package:kairete/features/newsfeed/screens/reply_screen.dart';

class MediaTypeController extends GetxController {
  MediaUsecase usecase = IMediaUsecase();
  var items = <MediaModel>[].obs;
  ArticlesUsecase articlesUsecase = IArticlesUsecase();

  MediaModel? item;

  @override
  void onInit() {
    if (Get.arguments['item'] != null) {
      item = Get.arguments['item'];
      fetchItems();
    }
    super.onInit();
  }

  void fetchItems() async {
    if (item != null) {
      if (item?.containerType == 'album') {
        final json = await usecase.getAlbum(id: item?.containerId ?? 0);
        items.value = json['media']
            .map<MediaModel>((e) => MediaModel.fromJson(e))
            .toList();
      } else {
        final json = await usecase.getCategory(id: item?.containerId ?? 0);
        items.value = json['media']
            .map<MediaModel>((e) => MediaModel.fromJson(e))
            .toList();
      }
    }
  }

  void onReactions({required int reactionId}) async {
    final json = await usecase.reactions(id: reactionId);
    if (json['success'] == true) {
      fetchItems();
    }
  }

  void showReactionPopup({required int newFeedId}) async {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(reactionId: reactionId);
      },
    );
  }

  void toReplies({required int newFeedId}) async {
    final newFeed = await fetchNewfeedItem(id: newFeedId);
    Get.to(() => ReplyScreen(), arguments: {'item': newFeed});
  }

  Future fetchNewfeedItem({required int id}) async {
    final json = await articlesUsecase.fetchNewfeedItem(id: id);
    final newFeed = NewsfeedModel.fromJson(json['newsfeedItem']);
    return newFeed;
  }
}
