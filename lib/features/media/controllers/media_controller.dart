import 'package:get/get.dart';
import 'package:kairete/components/kairete_popup.dart';
import 'package:kairete/features/articles/usecase/articles_usecase.dart';
import 'package:kairete/features/media/models/media_model.dart';
import 'package:kairete/features/media/screens/media_reply_screen.dart';
import 'package:kairete/features/media/screens/media_type_screen.dart';
import 'package:kairete/features/media/usecase/media_uscase.dart';
import 'package:url_launcher/url_launcher.dart';

class MediaController extends GetxController {
  MediaUsecase useCase = IMediaUsecase();
  ArticlesUsecase articlesUsecase = IArticlesUsecase();

  var items = <MediaModel>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    fetchItems();
  }

  void fetchItems() async {
    final json = await useCase.get();
    items.value =
        json['media'].map<MediaModel>((e) => MediaModel.fromJson(e)).toList();
  }

  void onReactions({required int reactionId, required MediaModel item}) async {
    final body = {
      'reaction_id': reactionId,
    };
    final json = await useCase.reactions(id: item.mediaId ?? 0, body: body);
    if (json['success'] == true) {
      fetchItems();
    }
  }

  void showReactionPopup({required MediaModel item}) async {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(reactionId: reactionId, item: item);
      },
    );
  }

  void toReplies({required MediaModel item}) async {
    Get.to(() => MediaReplyScreen(), arguments: {'item': item});
  }

  void toMediaType({required MediaModel item}) {
    Get.to(() => MediaTypeScreen(), arguments: {
      'item': item,
    });
  }

  void tolaunchURL({required String urlString}) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
