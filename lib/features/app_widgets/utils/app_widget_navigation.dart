import 'package:get/get.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_thread_list_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppWidgetNavigation {
  AppWidgetNavigation._();

  static Future<void> open(AppWidgetCard card) async {
    final type = card.actionType;
    final payload = card.actionPayload.trim();
    if (payload.isEmpty || type == 'none') return;

    switch (type) {
      case 'url':
        final uri = Uri.tryParse(payload);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      case 'thread':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          Get.to(() => ThreadDetailPage(threadId: id));
        }
        return;
      case 'forum':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          Get.to(
            () => ForumThreadListPage(forumId: id, forumTitle: card.title),
          );
        }
        return;
      case 'blog':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          Get.to(
            () => BlogListPage(filterBlogId: id, pageTitle: card.title),
          );
        }
        return;
      case 'blog_entry':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          Get.to(() => BlogDetailPage(entryId: id));
        }
        return;
      case 'media':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          Get.to(() => MediaDetailPage(mediaId: id));
        }
        return;
      case 'group':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          Get.to(() => GroupDetailPage(groupId: id));
        }
        return;
      case 'user_profile':
        final id = int.tryParse(payload) ?? 0;
        if (id > 0) {
          OmnifeedNavigation.openUserProfile(id);
        }
        return;
      default:
        return;
    }
  }
}
