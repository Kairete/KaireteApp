import 'package:flutter/material.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_card.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_comments.dart';

/// Card feed con commenti nidificati inline per i profile post.
class OmnifeedFeedCard extends StatefulWidget {
  const OmnifeedFeedCard({
    super.key,
    required this.item,
    this.onOpen,
    this.onComment,
    this.onReact,
    this.onBookmark,
    this.onShareInternal,
    this.onShareExternal,
    this.onAuthorTap,
    this.onBlogTap,
    this.onForumTap,
    this.onGroupTap,
    this.onMediaTap,
    this.onMediaCategoryTap,
    this.onFollow,
    this.onEdit,
    this.onDelete,
    this.onHighlight,
    this.onTagTap,
    this.showOwnerActions = false,
    this.onCommentsChanged,
  });

  final OmnifeedItem item;
  final VoidCallback? onOpen;
  final VoidCallback? onComment;
  final Future<void> Function(int reactionId)? onReact;
  final Future<void> Function()? onBookmark;
  final VoidCallback? onShareInternal;
  final VoidCallback? onShareExternal;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onBlogTap;
  final VoidCallback? onForumTap;
  final VoidCallback? onGroupTap;
  final VoidCallback? onMediaTap;
  final VoidCallback? onMediaCategoryTap;
  final VoidCallback? onFollow;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onHighlight;
  final void Function(String tag)? onTagTap;
  final bool showOwnerActions;
  final VoidCallback? onCommentsChanged;

  @override
  State<OmnifeedFeedCard> createState() => _OmnifeedFeedCardState();
}

class _OmnifeedFeedCardState extends State<OmnifeedFeedCard> {
  final _commentsKey = GlobalKey<OmnifeedFeedCommentsState>();

  @override
  Widget build(BuildContext context) {
    final supportsComments = widget.item.supportsInlineFeedComments;

    return OmnifeedCard(
      item: widget.item,
      onOpen: widget.onOpen,
      onComment: supportsComments
          ? () => _commentsKey.currentState?.focusComposer()
          : widget.onComment,
      onReact: widget.onReact,
      onBookmark: widget.onBookmark,
      onShareInternal: widget.onShareInternal,
      onShareExternal: widget.onShareExternal,
      onAuthorTap: widget.onAuthorTap,
      onBlogTap: widget.onBlogTap,
      onForumTap: widget.onForumTap,
      onGroupTap: widget.onGroupTap,
      onMediaTap: widget.onMediaTap,
      onMediaCategoryTap: widget.onMediaCategoryTap,
      onFollow: widget.onFollow,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onHighlight: widget.onHighlight,
      onTagTap: widget.onTagTap,
      showOwnerActions: widget.showOwnerActions,
      comments: supportsComments
          ? [
              OmnifeedFeedComments(
                key: _commentsKey,
                item: widget.item,
                onChanged: widget.onCommentsChanged,
              ),
            ]
          : const [],
    );
  }
}
