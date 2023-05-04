import 'package:get/get.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../../helper/user.dart';
import '../../blogs/screens/my_blog_screen.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/create_newsfeed_screen.dart';
import '../../newsfeed/screens/newsfeed_detail_screen.dart';
import '../../newsfeed/screens/reply_screen.dart';
import '../screens/user_profile_screen.dart';
import '../usecase/new_feed_profile_usecase.dart';

class UserProfileFeedController extends GetxController {
  NewFeedProfileUsecase? usecase;
  NewsFeedUsecase newsFeedUsecase = INewsFeedUsecase();

  int? id;
  var items = <NewsfeedModel>[].obs;

  @override
  void onInit() {
    id = Get.arguments['id'];
    usecase = INewFeedProfileUsecase(id);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    fechItems();
  }

  void fechItems() async {
    final body = {'id': id};
    final json = await usecase?.profilePost(body: body);
    items.value = json['newsfeedItems']
        .map<NewsfeedModel>((e) => NewsfeedModel.fromJson(e))
        .toList();
  }

  void toCreate() async {
    final data =
        await Get.to(() => CreateNewsfeedScreen(), fullscreenDialog: true);
    if (data != null) {
      fechItems();
    }
  }

  void toDetail({required NewsfeedModel item}) {
    Get.to(() => NewsfeedDetailScreen(), arguments: {'item': item});
  }

  void onReactions({required int postId, required int reactionId}) async {
    final body = {
      'id': postId,
      'reaction_id': reactionId,
    };
    final json = await newsFeedUsecase.reactions(body: body);
    if (json['success'] == true) {
      fechItems();
    }
  }

  void showReactionPopup({required NewsfeedModel item}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(postId: item.itemId ?? 0, reactionId: reactionId);
      },
    );
  }

  void toReplies({required NewsfeedModel item}) {
    Get.to(() => ReplyScreen(), arguments: {'item': item});
  }

  void toProfile({User? user}) {
    if (user != null) {
      Get.to(
        () => UserProfileScreen(),
        arguments: {'id': user.userId},
      );
    }
  }

  void toMyBlogs({BlogEntryItem? blog}) {
    Get.to(() => const MyBlogScreen(), arguments: {'blog': blog});
  }
}
