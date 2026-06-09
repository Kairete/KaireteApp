import 'package:get/get.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/blog/pages/blog_list_page.dart';
import 'package:kairete/features/forum/pages/forum_thread_list_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_detail_page.dart';
import 'package:kairete/features/profile/pages/user_profile_page.dart';

class OmnifeedNavigation {
  OmnifeedNavigation._();

  static void openAuthor(OmnifeedItem item) =>
      openUserProfile(item.author?.userId);

  static void openUserProfile(int? userId) {
    if (userId == null || userId <= 0) return;
    Get.to(() => UserProfilePage(userId: userId));
  }

  static void openBlog(OmnifeedItem item) {
    final blogId = item.blogId;
    if (blogId == null || blogId <= 0) return;
    Get.to(
      () => BlogListPage(
        filterBlogId: blogId,
        pageTitle: item.blogLabel ?? 'Blog',
      ),
    );
  }

  static void openForum(OmnifeedItem item) {
    final forumId = item.forumId;
    if (forumId == null || forumId <= 0) return;
    Get.to(
      () => ForumThreadListPage(
        forumId: forumId,
        forumTitle: item.categoryLabel ?? 'Forum',
      ),
    );
  }

  static void openDetail(OmnifeedItem item) {
    final contentId = item.contentId;
    switch (item.contentType) {
      case 'tl_group_post':
      case 'ksg_group_post':
        final groupId = item.groupId ?? _groupIdFromViewUrl(item.viewUrl);
        if (groupId != null && groupId > 0) {
          Get.to(() => GroupDetailPage(groupId: groupId));
          return;
        }
        break;
      case 'thread':
        if (contentId != null && contentId > 0) {
          Get.to(
            () => ThreadDetailPage(
              threadId: contentId,
              forumTitle: item.categoryLabel ?? item.moduleTitle,
            ),
          );
          return;
        }
        break;
      case 'ubs_blog_entry':
        if (contentId != null && contentId > 0) {
          Get.to(() => BlogDetailPage(entryId: contentId));
          return;
        }
        break;
    }
    Get.to(() => OmnifeedDetailPage(item: item));
  }

  static int? _groupIdFromViewUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(r'social-groups/[^./]+\.(\d+)').firstMatch(url);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }
}
