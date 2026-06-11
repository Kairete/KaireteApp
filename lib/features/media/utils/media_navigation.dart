import 'package:get/get.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/widgets/media_viewer.dart';

class MediaNavigation {
  MediaNavigation._();

  static void openViewer(MediaItem item) {
    Get.to(() => MediaViewerPage(item: item));
  }
}
