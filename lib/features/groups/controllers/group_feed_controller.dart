import 'package:get/get.dart';
import 'package:kairete/features/groups/model/group_detail_model/group_detail_model.dart';
import 'package:kairete/features/groups/model/group_detail_model/post.dart';
import 'package:kairete/features/groups/screens/reply_screen.dart';
import 'package:kairete/features/groups/usecase/group_usecase.dart';

import '../../../components/kairete_popup.dart';
import '../../blogs/screens/my_blog_screen.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/create_newsfeed_screen.dart';
import '../../newsfeed/screens/newsfeed_detail_screen.dart';
import '../../profile/screens/user_profile_screen.dart';
import '../model/group_detail_model/user.dart';
import '../usecase/create_group_usecase.dart';

class GroupFeedController extends GetxController {
  var items = <Post>[].obs;
  GroupUsecase usecase = IGroupUsecase();
  int? groupId;

  @override
  void onInit() {
    groupId = Get.arguments['groupId'];
    fechItems();
    super.onInit();
  }

  void fechItems() async {
    final body = {'id': groupId};
    final json = await usecase.fetchGoups(body: body);
    final item = GroupDetailModel.fromJson(json);
    items.value = item.posts ?? [];
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
    final json = await usecase.reactions(body: body);
    if (json['success'] == true) {
      fechItems();
    }
  }

  void showReactionPopup({required Post item}) {
    showReactionsPopup(
      onBack: (reactionId) {
        onReactions(postId: item.postId ?? 0, reactionId: reactionId);
      },
    );
  }

  void toReplies({required Post item}) async {
    final isUpdate = await Get.to(() => ReplyScreen(), arguments: {
      'item': item,
      'usecase': IGroupNormalUsecaseImpl(),
    });
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
