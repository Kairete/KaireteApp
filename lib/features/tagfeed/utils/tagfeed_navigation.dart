import 'package:get/get.dart';
import 'package:kairete/features/tagfeed/pages/tag_feed_page.dart';

class TagFeedNavigation {
  TagFeedNavigation._();

  static void openTag(String tag) {
    final clean = tag.trim().replaceFirst(RegExp(r'^#'), '');
    if (clean.isEmpty) return;
    Get.to(() => TagFeedPage(tag: clean));
  }
}
