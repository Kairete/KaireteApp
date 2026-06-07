import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/feed/widgets/feed_comment_bar.dart';
import 'package:kairete/features/feed/widgets/feed_compose_bar.dart';
import 'package:kairete/features/groups/models/group_post.dart';
import 'package:kairete/features/groups/models/group_post_comment.dart';
import 'package:kairete/features/groups/models/social_group.dart';
import 'package:kairete/features/groups/pages/group_compose_page.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/groups/widgets/group_cover_header.dart';
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

  SocialGroup? _group;
  List<GroupPost> _posts = const [];
  Map<int, List<GroupPostComment>> _commentsByPost = const {};
  int? _composePostId;
  bool _loading = true;
  bool _sending = false;
  bool _joinLoading = false;
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
      if (!mounted) return;
      setState(() {
        _group = group;
        _posts = postsPage.posts;
        _commentsByPost = comments;
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
    setState(() => _composePostId = groupPostId);
    _commentFocus.requestFocus();
  }

  void _clearComposeTarget() {
    setState(() => _composePostId = null);
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
      _clearComposeTarget();
      await _load();
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
                            ..._posts.map(_buildPostCard),
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
                        onSend: _sendComment,
                        replyLabel: 'Risposta al post',
                        onCancelReply: _clearComposeTarget,
                      ),
                  ],
                ),
    );
  }

  Widget _buildPostCard(GroupPost post) {
    final comments = _commentsByPost[post.groupPostId] ?? const [];

    return FeedCardShell(
      header: FeedCardHeaderBar(
        child: Row(
          children: [
            FeedCardAvatar(
              url: post.author?.avatarUrl,
              name: post.author?.username,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author?.username ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.authorName,
                    ),
                  ),
                  Text(
                    formatOmnifeedCardDate(post.postDate),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      ),
      comments: comments
          .map(
            (comment) => FeedCommentTile(
              authorName: comment.author?.username ?? '',
              avatarUrl: comment.author?.avatarUrl,
              dateLabel: formatOmnifeedCardDate(comment.commentDate),
              message: comment.messagePlainText,
              likeCount: comment.reactionScore,
              visitorReactionId: comment.visitorReactionId,
              showCommentButton: false,
              onLike: comment.canReact
                  ? (reactionId) => _reactToComment(
                        comment,
                        reactionId: reactionId,
                      )
                  : null,
            ),
          )
          .toList(),
    );
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
