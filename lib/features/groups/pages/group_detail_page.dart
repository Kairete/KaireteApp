import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/services/app_widgets_service.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_injector.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_placements.dart';
import 'package:kairete/features/app_widgets/widgets/app_widget_strip.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_compose_bar.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/groups/models/group_post.dart';
import 'package:kairete/features/groups/models/group_post_comment.dart';
import 'package:kairete/features/groups/models/social_group.dart';
import 'package:kairete/features/groups/pages/group_compose_page.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/groups/widgets/group_cover_header.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  final GroupsService _service = GroupsService();
  final _commentCtrl = TextEditingController();
  final _commentFocus = FocusNode();
  final _replyDraft = FeedCommentReplyDraft();
  SocialGroup? _group;
  List<GroupPost> _posts = const [];
  Map<int, List<GroupPostComment>> _commentsByPost = const {};
  final Map<int, int> _shareCounts = {};
  AppWidgetPayload _widgetsPayload = AppWidgetPayload.empty();
  int? _composePostId;
  bool _loading = true;
  bool _sending = false;
  bool _joinLoading = false;
  int? _highlightCommentId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final group = await _service.fetchGroup(widget.groupId);
      final postsPage = await _service.fetchPosts(widget.groupId);
      final comments = await _loadComments(postsPage.posts);
      final widgets = await AppWidgetsService.instance.fetch(
        AppWidgetPlacements.groupPosts,
        contextId: widget.groupId,
        forceRefresh: true,
      );
      if (!mounted) return;
      setState(() {
        _group = group;
        _posts = postsPage.posts;
        _commentsByPost = comments;
        _widgetsPayload = widgets;
        _loading = false;
      });
    } on GroupsException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Impossibile caricare il gruppo.';
        _loading = false;
      });
    }
  }

  Future<Map<int, List<GroupPostComment>>> _loadComments(
    List<GroupPost> posts,
  ) async {
    if (posts.isEmpty) return const {};

    final entries = await Future.wait(
      posts.map((post) async {
        try {
          final page = await _service.fetchComments(post.groupPostId);
          return MapEntry(post.groupPostId, page.comments);
        } catch (_) {
          return MapEntry(post.groupPostId, <GroupPostComment>[]);
        }
      }),
    );
    return Map.fromEntries(entries);
  }

  Future<void> _toggleMembership() async {
    final group = _group;
    if (group == null || _joinLoading) return;

    setState(() => _joinLoading = true);
    try {
      if (group.canJoin) {
        await _service.joinGroup(group.groupId);
        AppToast.success('Sei entrato nel gruppo.');
      } else if (group.canLeave) {
        await _service.leaveGroup(group.groupId);
        AppToast.success('Hai lasciato il gruppo.');
      }
      await _load();
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _joinLoading = false);
    }
  }

  Future<void> _openCompose() async {
    if (_group?.canPost != true) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GroupComposePage(groupId: widget.groupId),
      ),
    );
    if (created == true) await _load();
  }

  Future<void> _reactToPost(GroupPost post, {int reactionId = 1}) async {
    try {
      await _service.reactToPost(
        groupPostId: post.groupPostId,
        authorUserId: post.author?.userId,
        reactionId: reactionId,
      );
      await _load();
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    }
  }

  Future<void> _reactToComment(
    GroupPostComment comment, {
    int reactionId = 1,
  }) async {
    try {
      await _service.reactToComment(
        commentId: comment.commentId,
        authorUserId: comment.author?.userId,
        reactionId: reactionId,
      );
      await _load();
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    }
  }

  void _focusCommentOnPost(int groupPostId) {
    _replyDraft.clear();
    _commentCtrl.clear();
    setState(() => _composePostId = groupPostId);
    _commentFocus.requestFocus();
  }

  void _clearComposeTarget() {
    _replyDraft.clear();
    _commentCtrl.clear();
    setState(() {
      _composePostId = null;
      _highlightCommentId = null;
    });
  }

  void _beginReplyToComment(int groupPostId, FeedNestedCommentData comment) {
    setState(() => _composePostId = groupPostId);
    _replyDraft.beginFrom(comment);
    _replyDraft.primeComposer(_commentCtrl);
    setState(() {});
    requestCommentFocusAfterFrame(_commentFocus, mountedOn: this);
  }

  Future<void> _sendFromBar() async {
    if (_replyDraft.isActive && _composePostId != null) {
      await _sendReplyToComment(
        _composePostId!,
        _replyDraft.parentCommentId!,
        _replyDraft.messageForApi(_commentCtrl.text),
      );
    } else {
      await _sendComment();
    }
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty || _composePostId == null) return;

    setState(() => _sending = true);
    try {
      await _service.postComment(
        groupPostId: _composePostId!,
        message: text,
      );
      _commentCtrl.clear();
      _replyDraft.clear();
      _clearComposeTarget();
      await _load();
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendReplyToComment(
    int groupPostId,
    int parentCommentId,
    String message,
  ) async {
    if (message.trim().isEmpty) return;
    final beforeIds = (_commentsByPost[groupPostId] ?? const [])
        .map((c) => c.commentId)
        .toList();
    setState(() => _sending = true);
    try {
      await _service.postComment(
        groupPostId: groupPostId,
        message: message.trim(),
        parentCommentId: parentCommentId,
      );
      _replyDraft.clear();
      _commentCtrl.clear();
      await _load();
      if (!mounted) return;
      final nested = _mapGroupNestedComments(
        _commentsByPost[groupPostId] ?? const [],
      );
      setState(() {
        _composePostId = groupPostId;
        _highlightCommentId = detectNewNestedCommentId(
          previousIds: beforeIds,
          current: nested,
          parentCommentId: parentCommentId,
        );
      });
    } on GroupsException catch (e) {
      AppToast.error(e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  bool get _showCommentBar =>
      _group?.canPost == true && _composePostId != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        title: Text(_group?.title ?? 'Gruppo'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 8),
                          children: [
                            if (_group != null)
                              _GroupHeader(
                                group: _group!,
                                onJoinTap: _toggleMembership,
                                isJoinLoading: _joinLoading,
                              ),
                            if (_group?.canPost == true)
                              FeedComposeBar(
                                hintText: 'Scrivi qualcosa nel gruppo…',
                                onTapCompose: _openCompose,
                              ),
                            ...AppWidgetInjector.inject(
                              _posts,
                              _widgetsPayload,
                            ).map((slot) {
                              if (slot is SuggestionsRailMarker) {
                                return SuggestionsFeedRail(marker: slot);
                              }
                              if (slot is AppWidgetStripMarker) {
                                return AppWidgetStrip(widgets: slot.widgets);
                              }
                              return _buildPostCard(slot as GroupPost);
                            }),
                            if (_posts.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Text('Nessun post nel gruppo.'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_showCommentBar)
                      FeedCommentBar(
                        controller: _commentCtrl,
                        focusNode: _commentFocus,
                        isSending: _sending,
                        onSend: _sendFromBar,
                        replyLabel: _replyDraft.isActive
                            ? _replyDraft.replyLabel
                            : 'Commento al post',
                        onCancelReply: _clearComposeTarget,
                      ),
                  ],
                ),
    );
  }

  Widget _buildPostCard(GroupPost post) {
    final comments = _commentsByPost[post.groupPostId] ?? const [];
    void openAuthor() => OmnifeedNavigation.openUserProfile(
          post.author?.userId,
          username: post.author?.username,
        );

    return FeedCardShell(
      header: FeedCardAuthorHeader(
        avatarUrl: post.author?.avatarUrl,
        authorName: post.author?.username,
        dateLabel: formatOmnifeedCardDate(post.postDate),
        onAuthorTap: openAuthor,
        trailing: const SizedBox.shrink(),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Text(
          post.messagePlainText,
          style: const TextStyle(fontSize: 15, height: 1.35),
        ),
      ),
      footer: FeedCardActionBar(
        commentCount: post.commentCount,
        likeCount: post.reactionScore,
        visitorReactionId: post.visitorReactionId,
        onComment: post.canComment
            ? () => _focusCommentOnPost(post.groupPostId)
            : null,
        onReact: post.canReact
            ? (reactionId) => _reactToPost(post, reactionId: reactionId)
            : null,
        shareCount: _shareCounts[post.groupPostId] ?? 0,
        onShareInternal: () async {
          final result = await showFeedShareInternal(
            context: context,
            itemId: OmnifeedItemId.encode(
              OmnifeedItemId.typeGroupPost,
              post.groupPostId,
            ),
            previewText: post.messagePlainText,
          );
          if (result != null && mounted) {
            setState(() {
              _shareCounts[post.groupPostId] = result.shareCount;
            });
          }
        },
        onShareExternal: () async {
          final result = await showFeedShareExternal(
            context: context,
            itemId: OmnifeedItemId.encode(
              OmnifeedItemId.typeGroupPost,
              post.groupPostId,
            ),
            viewUrl: null,
          );
          if (result != null && mounted) {
            setState(() {
              _shareCounts[post.groupPostId] = result.shareCount;
            });
          }
        },
      ),
      comments: comments.isEmpty
          ? const []
          : [
              FeedNestedCommentThread(
                comments: _mapGroupNestedComments(comments),
                highlightCommentId: _highlightCommentId,
                onReplyTap: (comment) =>
                    _beginReplyToComment(post.groupPostId, comment),
              ),
            ],
    );
  }

  List<FeedNestedCommentData> _mapGroupNestedComments(
    List<GroupPostComment> comments,
  ) {
    final ids = comments.map((c) => c.commentId).toList();
    final parents = comments.map((c) => c.parentCommentId).toList();
    final depths = depthByCommentId(ids: ids, parentIds: parents);
    return comments
        .map(
          (comment) {
            final depth = depths[comment.commentId] ?? 0;
            return FeedNestedCommentData(
              id: comment.commentId,
              parentId: comment.parentCommentId,
              depthHint: depth,
              authorName: comment.author?.username ?? '',
              avatarUrl: comment.author?.avatarUrl,
              dateLabel: formatFeedCommentDate(comment.commentDate),
              message: comment.messagePlainText,
              likeCount: comment.reactionScore,
              visitorReactionId: comment.visitorReactionId,
              canReply: nestedCommentCanReply(depth),
              canLike: comment.canReact,
              onAuthorTap: () => OmnifeedNavigation.openUserProfile(
                comment.author?.userId,
                username: comment.author?.username,
              ),
              onLike: comment.canReact
                  ? (reactionId) => _reactToComment(
                        comment,
                        reactionId: reactionId,
                      )
                  : null,
            );
          },
        )
        .toList();
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.group,
    required this.onJoinTap,
    required this.isJoinLoading,
  });

  final SocialGroup group;
  final VoidCallback onJoinTap;
  final bool isJoinLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.cardBorder),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GroupCoverHeader(
            group: group,
            onJoinTap: onJoinTap,
            isJoinLoading: isJoinLoading,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(group.description, style: const TextStyle(height: 1.35)),
                ],
                const SizedBox(height: 8),
                Text(
                  '${group.memberCount} membri · ${group.postCount} post',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
