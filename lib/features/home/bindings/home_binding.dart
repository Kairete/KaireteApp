import 'package:get/get.dart';
import 'package:kairete/features/alerts/controllers/alerts_badge_controller.dart';
import 'package:kairete/features/auth/bindings/auth_binding.dart';
import 'package:kairete/features/blog/controllers/blog_list_controller.dart';
import 'package:kairete/features/forum/controllers/forum_list_controller.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/social_news/controllers/social_news_home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    AuthBinding().dependencies();
    if (!Get.isRegistered<OmnifeedController>()) {
      OmnifeedController.ensure();
    }
    if (!Get.isRegistered<AlertsBadgeController>()) {
      Get.put(AlertsBadgeController(), permanent: true);
    }
    if (!Get.isRegistered<BlogListController>(tag: 'blog_0_0')) {
      Get.put(BlogListController(), tag: 'blog_0_0', permanent: true);
    }
    if (!Get.isRegistered<ForumListController>()) {
      Get.put(ForumListController(), permanent: true);
    }
    if (!Get.isRegistered<SocialNewsHomeController>()) {
      Get.put(SocialNewsHomeController(), permanent: true);
    }
  }
}
