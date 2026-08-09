import 'package:kairete/features/forum/models/forum_node.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
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

/// Unisce liste feed per [OmnifeedItem.itemId].
///
/// Con [sortByItemDate] true (default) riordina per data pubblicazione.
/// Con false mantiene l'ordine della prima lista (serve per sort API
/// tipo last_comment / last_like) e appende solo gli id nuovi.
List<OmnifeedItem> mergeOmnifeedItemLists(
  Iterable<List<OmnifeedItem>> sources, {
  bool sortByItemDate = true,
}) {
  final sourceLists = sources.toList();
  if (!sortByItemDate && sourceLists.isNotEmpty) {
    final primaryOrder = <int>[];
    final byId = <int, OmnifeedItem>{};
    for (final item in sourceLists.first) {
      if (item.itemId <= 0) continue;
      if (!byId.containsKey(item.itemId)) {
        primaryOrder.add(item.itemId);
      }
      byId[item.itemId] = item;
    }
    final extras = <OmnifeedItem>[];
    for (final list in sourceLists.skip(1)) {
      for (final item in list) {
        if (item.itemId <= 0) continue;
        final existing = byId[item.itemId];
        if (existing == null) {
          byId[item.itemId] = item;
          extras.add(item);
        } else {
          byId[item.itemId] = mergeOmnifeedItems(existing, item);
        }
      }
    }
    return [
      for (final id in primaryOrder) byId[id]!,
      ...extras,
    ];
  }

  final byId = <int, OmnifeedItem>{};
  for (final list in sourceLists) {
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

/// Arricchisce header album media e titoli forum mancanti nel feed.
Future<List<OmnifeedItem>> enrichFeedItemHeaders(List<OmnifeedItem> items) async {
  final withMedia = await enrichMediaAlbumHeaders(items);
  return enrichForumThreadHeaders(withMedia);
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

/// Risolve il titolo forum per thread feed quando manca in payload OmniFeed.
Future<List<OmnifeedItem>> enrichForumThreadHeaders(
  List<OmnifeedItem> items, {
  int maxLookups = 20,
}) async {
  final targets = items
      .where(
        (item) =>
            item.contentType == 'thread' &&
            (item.headerModuleLabel == null || item.headerModuleLabel!.isEmpty) &&
            (item.forumId ?? 0) > 0,
      )
      .take(maxLookups)
      .toList();
  if (targets.isEmpty) return items;

  final nodeTitles = <int, String>{};
  try {
    final groups = await ForumService().fetchForumGroups();
    for (final ForumNodeGroup group in groups) {
      for (final forum in group.forums) {
        nodeTitles[forum.nodeId] = forum.title;
      }
    }
  } catch (_) {
    return items;
  }
  if (nodeTitles.isEmpty) return items;

  return items.map((item) {
    if (item.contentType != 'thread') return item;
    if (item.headerModuleLabel?.trim().isNotEmpty == true) return item;
    final forumId = item.forumId ?? 0;
    if (forumId <= 0) return item;
    final title = nodeTitles[forumId];
    if (title == null || title.trim().isEmpty) return item;
    return OmnifeedItem(
      itemId: item.itemId,
      contentType: item.contentType,
      contentId: item.contentId,
      contentTitle: item.contentTitle,
      messagePlainText: item.messagePlainText,
      messageParsed: item.messageParsed,
      itemDate: item.itemDate,
      commentCount: item.commentCount,
      reactionScore: item.reactionScore,
      visitorReactionId: item.visitorReactionId,
      author: item.author,
      categoryLabel: title,
      blogLabel: item.blogLabel,
      blogId: item.blogId,
      blogCategoryId: item.blogCategoryId,
      forumId: item.forumId,
      albumId: item.albumId,
      albumLabel: item.albumLabel,
      mediaCategoryId: item.mediaCategoryId,
      mediaThumbnailUrl: item.mediaThumbnailUrl,
      mediaUrl: item.mediaUrl,
      mediaType: item.mediaType,
      mediaDurationSeconds: item.mediaDurationSeconds,
      viewUrl: item.viewUrl,
      groupId: item.groupId,
      tags: item.tags,
      attachments: item.attachments,
    );
  }).toList();
}
