import 'package:get/get.dart';
import 'package:kairete/constants/app_routes.dart';
import 'package:kairete/constants/key_constant.dart';
import 'package:kairete/features/login/models/user_model.dart';
import 'package:kairete/features/profile/screens/user_profile_free_screen.dart';
import 'package:kairete/features/profile/usecase/user_profile_usecase.dart';
import 'package:kairete/helper/user.dart';
import 'package:kairete/local/data_local.dart';

import '../../../helper/notification_service.dart';
import '../../newsfeed/usecase/newsfeed_usecase.dart';
import '../../../components/kairete_popup.dart';
import '../../blogs/screens/my_blog_screen.dart';
import '../../newsfeed/models/newsfeed_model.dart';
import '../../newsfeed/screens/create_newsfeed_screen.dart';
import '../../newsfeed/screens/newsfeed_detail_screen.dart';
import '../../newsfeed/screens/reply_screen.dart';
import '../screens/user_profile_screen.dart';
import '../usecase/new_feed_profile_usecase.dart';

class UserProfileController extends GetxController {
  var user = User().obs;
  UserProfileUsecase usecase = IUserProfileUsecase();
  NewsFeedUsecase newsFeedUsecase = INewsFeedUsecase();
  NewFeedProfileUsecase? newFeedProfileUsecase;

  int? id;
  var items = <NewsfeedModel>[].obs;
  var isCurrentUser = true;

  @override
  void onInit() {
    if (Get.arguments != null) {
      isCurrentUser = false;
      id = Get.arguments['id'];
    } else {
      id = UserManager.instance.userId;
    }
    newFeedProfileUsecase = INewFeedProfileUsecase(id);
    fetchItems();
    super.onInit();
  }

  void fetchItems() async {
    if (id != null) {
      final body = {'id': id};
      final json = await usecase.fetchUser(body: body);
      user.value = User.fromJson(json['user']);
    } else {
      final json = await usecase.fetchData();
      user.value = User.fromJson(json['me']);
    }
    items.refresh();
    fechFeed();
  }

  void fechFeed() async {
    final body = {'id': id};
    final json = await newFeedProfileUsecase?.profilePost(body: body);
    items.value = json['newsfeedItems']
        .map<NewsfeedModel>((e) => NewsfeedModel.fromJson(e))
        .toList();
  }

  void toProfilePost() {
    Get.to(() => UserProfileFeedScreen(), arguments: {
      'id': id ?? UserManager.instance.userId,
    });
  }

  void onLogout() async {
    // NotificationManager.instance.disableNotice();
    print("=====a");
    await NotificationManager.instance.deleteFCM();
    print("=====b");

    await LocalManager.instance.remove(key: PreferencesKey.token);
    UserManager.instance.userId = null;
    Get.offAllNamed(Routes.login);
  }

  void onFollow() async {
    final body = {
      'reaction_id': 1,
      'id': user.value.userId,
    };
    final json = await usecase.follow(body: body);
    if (json != null) {
      user.value.isFollowed = json['action'] == 'follow' ? true : false;
      user.refresh();
    }
  }

  //feed
  void toCreate() async {
    final data =
        await Get.to(() => CreateNewsfeedScreen(), fullscreenDialog: true);
    if (data != null) {
      fechFeed();
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
      fechFeed();
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
    Get.to(() => MyBlogScreen(), arguments: {'blog': blog});
  }

  void onDeleteItem({required int id}) async {
    final useCase = INewsFeedUsecase();
    showKairetePopup(
      onTapDone: () async {
        final json = await useCase.delete(id: id);
        if (json != null) {
          fechFeed();
        }
      },
      title: 'Delete',
      content: 'Are you sure you want to delete this item?',
      cancelTitle: 'cancel',
    );
  }
}
