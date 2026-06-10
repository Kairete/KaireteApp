import 'package:kairete/core/utils/api_url.dart';

class FeedAttachment {
  const FeedAttachment({
    this.thumbnailUrl,
    this.directUrl,
    this.filename,
  });

  final String? thumbnailUrl;
  final String? directUrl;
  final String? filename;

  String? get displayImageUrl {
    final thumb = ApiUrl.resolve(thumbnailUrl);
    if (thumb.isNotEmpty) return thumb;
    final direct = ApiUrl.resolve(directUrl);
    if (direct.isNotEmpty) return direct;
    return null;
  }

  static List<FeedAttachment> parseList(dynamic raw) {
    if (raw is! List) return const [];
    final out = <FeedAttachment>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      out.add(
        FeedAttachment(
          thumbnailUrl: map['thumbnail_url']?.toString(),
          directUrl: map['direct_url']?.toString(),
          filename: map['filename']?.toString(),
        ),
      );
    }
    return out;
  }

  static List<String> imageUrlsFrom(dynamic raw) {
    return parseList(raw)
        .map((a) => a.displayImageUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }
}
