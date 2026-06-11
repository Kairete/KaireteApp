import 'package:get/get.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/media/widgets/media_viewer.dart';

class MediaNavigation {
  MediaNavigation._();

  static void openViewer(MediaItem item) {
    Get.to(() => MediaViewerPage(item: item));
  }

  static Future<void> openPublishedMedia(int? mediaId) async {
    if (mediaId == null || mediaId <= 0) return;
    await Get.off(() => MediaDetailPage(mediaId: mediaId));
  }
}
