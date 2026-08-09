import 'package:get/get.dart';
import 'package:kairete/features/alerts/services/alerts_service.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_detail_page.dart';

/// Deep link da payload FCM (`content_type` + `content_id`).
class PushNavigation {
  PushNavigation._();

  static final AlertsService _alertsService = AlertsService();

  static Future<bool> openFromData(Map<String, dynamic> data) async {
    final type = data['content_type']?.toString();
    final rawId = data['content_id']?.toString();
    final contentId = int.tryParse(rawId ?? '') ?? 0;
    if (type == null || type.isEmpty || contentId <= 0) {
      return false;
    }

    switch (type) {
      case 'thread':
        Get.to(() => ThreadDetailPage(threadId: contentId));
        return true;
      case 'post':
        final threadId =
            await _alertsService.resolveThreadIdForPost(contentId);
        if (threadId != null && threadId > 0) {
          Get.to(() => ThreadDetailPage(threadId: threadId));
          return true;
        }
        return false;
      case 'ubs_blog_entry':
      case 'blog_post':
        Get.to(() => BlogDetailPage(entryId: contentId));
        return true;
      case 'ubs_blog':
      case 'ubs_comment':
        Get.to(() => BlogDetailPage(entryId: contentId));
        return true;
      case 'xfmg_media':
        Get.to(() => MediaDetailPage(mediaId: contentId));
        return true;
      case 'tl_group_post':
      case 'social_group':
        Get.to(() => GroupDetailPage(groupId: contentId));
        return true;
      case 'profile_post':
      case 'profile_post_comment':
        Get.to(
          () => OmnifeedDetailPage(
            item: OmnifeedItem(itemId: contentId),
          ),
        );
        return true;
      default:
        return false;
    }
  }
}
