import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/utils/feed_comment_display.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';

/// Commento visualizzabile in un thread nidificato.
class FeedNestedCommentData {
  const FeedNestedCommentData({
    required this.id,
    required this.parentId,
    required this.authorName,
    required this.message,
    this.avatarUrl,
    this.dateLabel,
    this.messageHtml,
    this.likeCount = 0,
    this.visitorReactionId,
    this.depthHint = 0,
    this.canReply = true,
    this.canLike = true,
    this.onAuthorTap,
    this.onLike,
  });

  final int id;
  final int parentId;
  final String authorName;
  final String message;
  final String? avatarUrl;
  final String? dateLabel;
  final String? messageHtml;
  final int likeCount;
  final int? visitorReactionId;
  final int depthHint;
  final bool canReply;
  final bool canLike;
  final VoidCallback? onAuthorTap;
  final Future<void> Function(int reactionId)? onLike;

  FeedNestedCommentData copyWith({
    int? likeCount,
    int? visitorReactionId,
    bool? canLike,
    Future<void> Function(int reactionId)? onLike,
    bool clearOnLike = false,
  }) {
    return FeedNestedCommentData(
      id: id,
      parentId: parentId,
      authorName: authorName,
      message: message,
      avatarUrl: avatarUrl,
      dateLabel: dateLabel,
      messageHtml: messageHtml,
      likeCount: likeCount ?? this.likeCount,
      visitorReactionId: visitorReactionId ?? this.visitorReactionId,
      depthHint: depthHint,
      canReply: canReply,
      canLike: canLike ?? this.canLike,
      onAuthorTap: onAuthorTap,
      onLike: clearOnLike ? null : (onLike ?? this.onLike),
    );
  }
}

/// Thread commenti nidificati. Il tap su Rispondi delega al compositore esterno.
class FeedNestedCommentThread extends StatefulWidget {
  const FeedNestedCommentThread({
    super.key,
    required this.comments,
    this.onReplyTap,
    this.highlightCommentId,
  });

  final List<FeedNestedCommentData> comments;
  final void Function(FeedNestedCommentData comment)? onReplyTap;
  final int? highlightCommentId;

  @override
  State<FeedNestedCommentThread> createState() =>
      _FeedNestedCommentThreadState();
}

class _FeedNestedCommentThreadState extends State<FeedNestedCommentThread> {
  final _tileKeys = <int, GlobalKey>{};
  int? _activeHighlightId;

  @override
  void didUpdateWidget(FeedNestedCommentThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextId = widget.highlightCommentId;
    if (nextId != null && nextId != oldWidget.highlightCommentId) {
      _scrollToComment(nextId);
    }
  }

  void _scrollToComment(int commentId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _tileKeys[commentId];
      final ctx = key?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
      setState(() => _activeHighlightId = commentId);
      Future<void>.delayed(const Duration(milliseconds: 2400), () {
        if (mounted && _activeHighlightId == commentId) {
          setState(() => _activeHighlightId = null);
        }
      });
    });
  }

  GlobalKey _keyFor(int id) => _tileKeys.putIfAbsent(id, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    if (widget.comments.isEmpty) return const SizedBox.shrink();

    final tree = _buildCommentTree(widget.comments);
    final byId = {for (final c in widget.comments) c.id: c};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final node in tree)
          KeyedSubtree(
            key: _keyFor(node.id),
            child: _NestedCommentTile(
              comment: byId[node.id]!,
              depth: node.depth,
              highlighted: _activeHighlightId == node.id,
              onReplyTap: widget.onReplyTap == null
                  ? null
                  : (byId[node.id]?.canReply ?? false) && node.depth < 8
                      ? () => widget.onReplyTap!(byId[node.id]!)
                      : null,
            ),
          ),
      ],
    );
  }
}

List<FeedCommentTreeNode> _buildCommentTree(
  List<FeedNestedCommentData> comments,
) {
  if (comments.isEmpty) return const [];

  final ids = comments.map((c) => c.id).toList();
  final parentIds = comments.map((c) => c.parentId).toList();
  final flat = flattenFeedComments(ids: ids, parentIds: parentIds);
  final hintById = {for (final c in comments) c.id: c.depthHint};

  return flat
      .map(
        (node) => FeedCommentTreeNode(
          id: node.id,
          parentId: node.parentId,
          depth: _maxDepth(node.depth, hintById[node.id] ?? 0),
        ),
      )
      .toList();
}

int _maxDepth(int computed, int hint) {
  if (hint > computed) return hint;
  return computed;
}

class _NestedCommentTile extends StatelessWidget {
  const _NestedCommentTile({
    required this.comment,
    required this.depth,
    this.onReplyTap,
    this.highlighted = false,
  });

  final FeedNestedCommentData comment;
  final int depth;
  final VoidCallback? onReplyTap;
  final bool highlighted;

  static const _nestedBg = Color(0xFFEBEBEB);

  @override
  Widget build(BuildContext context) {
    final nested = depth > 0;
    final isNestedReply = comment.parentId > 0 || nested;
    final message = FeedCommentDisplay.formatNestedReplyDisplay(
      comment.message,
      isNested: isNestedReply,
    );
    final messageHtml = isNestedReply
        ? null
        : FeedCommentDisplay.stripReplyQuoteHtml(
            comment.messageHtml,
            isNestedReply: false,
          );
    final tile = FeedCommentTile(
      authorName: comment.authorName,
      avatarUrl: comment.avatarUrl,
      dateLabel: comment.dateLabel,
      message: message,
      messageHtml: messageHtml,
      likeCount: comment.likeCount,
      visitorReactionId: comment.visitorReactionId,
      showCommentButton: onReplyTap != null,
      onAuthorTap: comment.onAuthorTap,
      onLike: comment.canLike ? comment.onLike : null,
      onComment: onReplyTap,
      compactPadding: true,
      compactDense: nested,
      avatarSize: nested
          ? FeedCommentLayout.avatarSize
          : FeedCommentLayout.rootAvatarSize,
      transparentBackground: true,
    );

    if (!nested) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: highlighted
              ? Border.all(color: AppTheme.brandPrimary, width: 2)
              : null,
          color: highlighted ? AppTheme.brandPrimary.withOpacity(0.06) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeedCommentLayout.cardInsetLeft,
            6,
            FeedCommentLayout.cardInsetRight,
            4,
          ),
          child: tile,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: FeedCommentLayout.cardInsetLeft +
            FeedCommentLayout.marginForDepth(depth),
        right: FeedCommentLayout.nestedRightInset,
        bottom: 3,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: highlighted
              ? AppTheme.brandPrimary.withOpacity(0.12)
              : _nestedBg,
          borderRadius: BorderRadius.circular(6),
          border: highlighted
              ? Border.all(color: AppTheme.brandPrimary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FeedCommentLayout.nestedTilePaddingLeft,
            FeedCommentLayout.nestedTilePaddingTop,
            FeedCommentLayout.nestedTilePaddingRight,
            FeedCommentLayout.nestedTilePaddingBottom,
          ),
          child: tile,
        ),
      ),
    );
  }
}
