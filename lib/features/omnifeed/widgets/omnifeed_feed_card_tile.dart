import 'package:flutter/material.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_card.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

/// Card feed condivisa tra News feed e tab Social News.
class OmnifeedFeedCardTile extends StatelessWidget {
  const OmnifeedFeedCardTile({
    super.key,
    required this.item,
    required this.controller,
    this.onCommentsChanged,
  });

  final OmnifeedItem item;
  final OmnifeedController controller;
  final VoidCallback? onCommentsChanged;

  @override
  Widget build(BuildContext context) {
    return OmnifeedFeedCard(
      key: ValueKey(item.itemId),
      item: item,
      onOpen: () => controller.openDetail(item),
      onComment: () => controller.openDetail(item),
      onAuthorTap: () => controller.openAuthor(item),
      onFollow: controller.canShowFollow(item)
          ? () => controller.followAuthor(item)
          : null,
      onBlogTap: item.contentType == 'ubs_blog_entry'
          ? () => controller.openBlog(item)
          : null,
      onForumTap: item.contentType == 'thread'
          ? () => controller.openForum(item)
          : null,
      onMediaTap: item.contentType == 'xfmg_media'
          ? () => OmnifeedNavigation.openMediaAlbum(item)
          : null,
      onMediaCategoryTap: item.contentType == 'xfmg_media'
          ? () => OmnifeedNavigation.openMediaCategory(item)
          : null,
      onReact: (reactionId) => controller.react(item, reactionId: reactionId),
      onBookmark: () => controller.toggleBookmark(item),
      onShareInternal: () async {
        final result = await showFeedShareInternal(
          context: context,
          itemId: item.itemId,
          previewText: item.messagePlainText ?? item.contentTitle,
        );
        if (result != null) {
          controller.applyShareResult(item.itemId, result);
        }
      },
      onShareExternal: () async {
        final result = await showFeedShareExternal(
          context: context,
          itemId: item.itemId,
          viewUrl: item.viewUrl,
        );
        if (result != null) {
          controller.applyShareResult(item.itemId, result);
        }
      },
      onTagTap: TagFeedNavigation.openTag,
      showOwnerActions: controller.isOwnedByCurrentUser(item),
      onEdit: () => controller.editItem(item),
      onDelete: () => controller.deleteItem(item),
      onHighlight: (item.canHighlight || item.isHighlighted)
          ? () => controller.toggleHighlight(item)
          : null,
      onCommentsChanged: onCommentsChanged,
    );
  }
}
