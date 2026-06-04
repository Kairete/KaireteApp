import 'package:get/get.dart';
import 'package:kairete/features/articles/models/articles_model.dart';
import 'package:kairete/features/articles/screens/articles_detail_screen.dart';
import 'package:kairete/features/forum/screens/thread_detail_screen.dart';
import 'package:kairete/features/newsfeed/models/newsfeed_model.dart';

import '../features/blogs/screens/blog_detail_screen.dart';
import '../features/forum/models/forum_detail_model.dart';
import '../features/newsfeed/screens/newsfeed_detail_screen.dart';

abstract class FCMNavigator {
  void nextStep({dynamic data});
}

class IFCMNavigator implements FCMNavigator {
  @override
  void nextStep({dynamic data}) {
    final type = data['content_type'];
    int? id = int.parse(data['content_id']);
    switch (type) {
      case 'profile_post':
        toNewfeed(id);
        break;
      case 'profile_post_comment':
        toNewfeed(id);
        break;
      case 'ubs_blog_entry':
        toBlog(id);
        break;
      case 'ubs_blog':
        toBlog(id);
        break;
      case 'ubs_comment':
        toBlog(id);
        break;
      case 'ams_article':
        toArticle(id);
        break;
      case 'ams_comment':
        toArticle(id);
        break;
      case 'thread':
        toThred(id);
        break;
      case 'post':
        toThred(id);
        break;
      default:
    }
  }

  void toArticle(int? id) {
    final aritcle = ArticleItems(articleId: id);
    Get.to(() => ArticlesDetailScreen(), arguments: {
      'item': aritcle,
    });
  }

  void toBlog(int? id) {
    final blog = BlogEntryItem(blogEntryId: id);
    Get.to(() => BlogDetailScreen(), arguments: {
      'item': blog,
    });
  }

  void toNewfeed(int? id) {
    final newfeed = NewsfeedModel(itemId: id);
    Get.to(() => NewsfeedDetailScreen(), arguments: {'item': newfeed});
  }

  void toThred(int? id) {
    final thread = Threads(firstPostId: id);
    Get.to(() => ThreadDetailScreen(), arguments: {'item': thread});
  }

  void toGroup() {}
}
