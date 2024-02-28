import 'package:get/get.dart';
import 'package:kairete/features/groups/usecase/create_group_usecase.dart';
import 'package:kairete/features/groups/usecase/group_usecase.dart';
import 'package:kairete/features/newsfeed/usecase/newsfeed_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../blogs/screens/my_blog_screen.dart';
import '../../login/models/user_model.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/create_newsfeed_screen.dart';
import '../../newsfeed/screens/newsfeed_detail_screen.dart';
import '../../newsfeed/screens/reply_screen.dart';
import '../../profile/screens/user_profile_screen.dart';

class NewFeedGroupController extends GetxController {
  var items = <NewsfeedModel>[].obs;
  GroupUsecase usecase = IGroupUsecase();
  NewsFeedUsecase newsFeedUsecase = INewsFeedUsecase();
  int? groupId;

  @override
  void onInit() {
    groupId = Get.arguments['groupId'];
    fechItems();
    print(groupId);
    super.onInit();
  }

  void fechItems() async {
    final body = {'group_id': groupId};
    final json = await usecase.fetchFeed(body: body);
    final item = BaseNewsfeedModel.fromJson(json);
    items.value = item.newsfeedItems ?? [];
  }

  void toDetail({required NewsfeedModel item}) {
    Get.to(() => NewsfeedDetailScreen(), arguments: {'item': item});
  }

  void toCreate() async {
    final grUsecase = ICreateGroupUsecaseImpl(groupId);
    final data = await Get.to(() => CreateNewsfeedScreen(),
        fullscreenDialog: true,
        arguments: {
          'usecase': grUsecase,
        });
    if (data != null) {
      fechItems();
    }
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

  void toReplies({required NewsfeedModel item}) async {
    final isUpdate =
        await Get.to(() => ReplyScreen(), arguments: {'item': item});
    if (isUpdate) {
      fechItems();
    }
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
