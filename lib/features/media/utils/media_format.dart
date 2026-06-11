import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

String formatMediaMetaDateLine({
  int? mediaDate,
  String? categoryTitle,
}) {
  final date = formatOmnifeedCardDate(mediaDate);
  final category = categoryTitle?.trim();
  if (category == null || category.isEmpty) return date;
  return '$date - $category';
}

String mediaItemMetaDateLine(MediaItem item) =>
    formatMediaMetaDateLine(
      mediaDate: item.mediaDate,
      categoryTitle: item.category?.title,
    );

String omnifeedMediaMetaDateLine(OmnifeedItem item) =>
    formatMediaMetaDateLine(
      mediaDate: item.itemDate,
      categoryTitle: item.categoryLabel,
    );
