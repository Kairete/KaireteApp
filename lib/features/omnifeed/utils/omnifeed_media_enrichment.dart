import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

/// Unisce due item feed con lo stesso [OmnifeedItem.itemId], preferendo campi
/// album/autore/thumbnail più completi (fix merge che scartava i dati nativi XFMG).
OmnifeedItem mergeOmnifeedItems(OmnifeedItem a, OmnifeedItem b) {
  if (a.itemId != b.itemId || a.itemId <= 0) {
    return mediaHeaderRichness(a) >= mediaHeaderRichness(b) ? a : b;
  }
  return a.mergedWith(b);
}

int mediaHeaderRichness(OmnifeedItem item) {
  var score = 0;
  if (item.albumLabel?.trim().isNotEmpty == true) score += 8;
  if ((item.albumId ?? 0) > 0) score += 2;
  if (item.author?.displayName?.trim().isNotEmpty == true) score += 2;
  if (item.mediaThumbnailUrl?.trim().isNotEmpty == true) score += 1;
  if (item.categoryLabel?.trim().isNotEmpty == true) score += 1;
  return score;
}

List<OmnifeedItem> mergeOmnifeedItemLists(Iterable<List<OmnifeedItem>> sources) {
  final byId = <int, OmnifeedItem>{};
  for (final list in sources) {
    for (final item in list) {
      if (item.itemId <= 0) continue;
      final existing = byId[item.itemId];
      byId[item.itemId] =
          existing == null ? item : mergeOmnifeedItems(existing, item);
    }
  }
  return byId.values.toList()
    ..sort((a, b) => (b.itemDate ?? 0).compareTo(a.itemDate ?? 0));
}

/// Carica titolo album (e autore) dall'API nativa XFMG quando il feed OmniFeed
/// non li include — tipico se il forum non ha ancora OmniFeed 1.7.77+.
Future<List<OmnifeedItem>> enrichMediaAlbumHeaders(
  List<OmnifeedItem> items, {
  int maxLookups = 15,
}) async {
  final targets = items
      .where(
        (item) =>
            item.contentType == 'xfmg_media' &&
            item.headerAlbumLabel == null &&
            (item.contentId ?? 0) > 0,
      )
      .take(maxLookups)
      .toList();
  if (targets.isEmpty) return items;

  final mediaService = MediaService();
  final resolved = <int, MediaItem>{};
  await Future.wait(
    targets.map((item) async {
      final id = item.contentId!;
      try {
        resolved[id] = await mediaService.fetchMediaItem(id);
      } catch (_) {}
    }),
  );
  if (resolved.isEmpty) return items;

  return items
      .map(
        (item) => item.enrichedFromMedia(resolved[item.contentId ?? 0]),
      )
      .toList();
}
