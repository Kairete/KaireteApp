import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/feed/utils/feed_comment_reply.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
import 'package:kairete/features/forum/utils/forum_react_guard.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

class ThreadDetailController extends GetxController {
  ThreadDetailController({
    required this.threadId,
    this.forumTitle,
  });

  final int threadId;
  final String? forumTitle;
  final ForumService _service = ForumService();
  final replyCtrl = TextEditingController();
  final replyFocus = FocusNode();
  final replyDraft = FeedCommentReplyDraft();
  final repliesKey = GlobalKey();

  final thread = Rxn<ForumThread>();
  final replies = <ForumPost>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSending = false.obs;
  final isReacting = false.obs;
  final errorMessage = ''.obs;
  final hasMoreReplies = false.obs;
  final totalReplies = 0.obs;
  final highlightReplyId = RxnInt();

  int _repliesPage = 1;
  int? _mainPostId;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    replyCtrl.dispose();
    replyFocus.dispose();
    super.onClose();
  }

  int get mainPostReactionScore {
    final current = thread.value;
    if (current == null) return 0;
    return current.firstPostReactionScore;
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    _repliesPage = 1;
    try {
      final page = await _service.fetchPostsPage(threadId, page: 1);
      final loaded = await _service.fetchThread(
        threadId,
        forumTitle: forumTitle,
        postsPage: page,
      );
      thread.value = loaded;
      _applyPostsPage(page, reset: true, replyCount: loaded.replyCount);
    } on ForumException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Impossibile caricare la discussione.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreReplies() async {
    if (isLoadingMore.value || !hasMoreReplies.value) return;
    isLoadingMore.value = true;
    try {
      final page = await _service.fetchPostsPage(
        threadId,
        page: _repliesPage + 1,
      );
      _repliesPage++;
      _applyPostsPage(page, reset: false);
    } on ForumException catch (e) {
      ForumReactGuard.notifyError(e.message);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _applyPostsPage(
    ForumPostsPage page, {
    required bool reset,
    int? replyCount,
  }) {
    ForumPost? firstPost;
    for (final post in page.posts) {
      if (post.isFirstPost) {
        firstPost = post;
        break;
      }
    }
    firstPost ??= page.posts.isNotEmpty ? page.posts.first : null;
    _mainPostId = firstPost?.postId;

    final replyPosts =
        page.posts.where((post) => !post.isFirstPost).toList(growable: false);
    if (reset) {
      replies.value = replyPosts;
    } else {
      replies.addAll(replyPosts);
    }
    hasMoreReplies.value = page.hasMore;
    totalReplies.value = replyCount ?? replies.length;
  }

  Future<void> react({int reactionId = 1}) async {
    final current = thread.value;
    if (current == null) return;

    final postId = _mainPostId ?? current.firstPostId;
    if (postId == null || postId <= 0) {
      ForumReactGuard.notifyBlocked('Post non disponibile.');
      return;
    }

    final userId = await ForumReactGuard.currentUserId();
    final blocked = ForumReactGuard.blockMessage(
      userId: userId,
      contentAuthorId: current.author?.userId,
    );
    if (blocked != null) {
      ForumReactGuard.notifyBlocked(blocked);
      return;
    }

    await _reactToPost(postId, reactionId: reactionId);
  }

  Future<void> reactToReply(ForumPost post, {int reactionId = 1}) async {
    if (post.postId <= 0) return;

    final userId = await ForumReactGuard.currentUserId();
    final blocked = ForumReactGuard.blockMessage(
      userId: userId,
      contentAuthorId: post.author?.userId,
    );
    if (blocked != null) {
      ForumReactGuard.notifyBlocked(blocked);
      return;
    }

    await _reactToPost(post.postId, reactionId: reactionId);
  }

  Future<void> _reactToPost(int postId, {int reactionId = 1}) async {
    if (isReacting.value) return;
    isReacting.value = true;
    try {
      final action = await _service.reactToPost(
        postId: postId,
        reactionId: reactionId,
      );
      _applyLocalReaction(postId, action);
      await _refreshAfterReact();
      ForumReactGuard.notifySuccess(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
    } on ForumException catch (e) {
      ForumReactGuard.notifyError(e.message);
    } on DioException catch (e) {
      ForumReactGuard.notifyError(XenforoApi.connectionMessage(e));
    } finally {
      isReacting.value = false;
    }
  }

  void _applyLocalReaction(int postId, String action) {
    final delta = action == 'delete' ? -1 : 1;
    final current = thread.value;
    final mainId = _mainPostId ?? current?.firstPostId;
    if (current != null && mainId == postId) {
      final score = current.firstPostReactionScore + delta;
      thread.value = current.copyWith(
        firstPostReactionScore: score < 0 ? 0 : score,
      );
      return;
    }
    final index = replies.indexWhere((p) => p.postId == postId);
    if (index < 0) return;
    final post = replies[index];
    final score = post.reactionScore + delta;
    replies[index] = ForumPost(
      postId: post.postId,
      threadId: post.threadId,
      messagePlainText: post.messagePlainText,
      messageParsed: post.messageParsed,
      postDate: post.postDate,
      reactionScore: score < 0 ? 0 : score,
      isFirstPost: post.isFirstPost,
      parentPostId: post.parentPostId,
      author: post.author,
      canReact: post.canReact,
      attachments: post.attachments,
      canEdit: post.canEdit,
      canDelete: post.canDelete,
    );
    replies.refresh();
  }

  Future<void> _refreshAfterReact() async {
    try {
      final page = await _service.fetchPostsPage(threadId, page: 1);
      final loaded = await _service.fetchThread(
        threadId,
        forumTitle: forumTitle,
        postsPage: page,
      );
      thread.value = loaded;
      _applyPostsPage(page, reset: true, replyCount: loaded.replyCount);
    } on ForumException catch (e) {
      ForumReactGuard.notifyError(e.message);
    } on DioException catch (e) {
      ForumReactGuard.notifyError(XenforoApi.connectionMessage(e));
    }
  }

  void beginReply(FeedNestedCommentData comment) {
    replyDraft.beginFrom(comment);
    replyDraft.primeComposer(replyCtrl);
    requestCommentFocusAfterFrame(replyFocus);
  }

  void cancelReply() {
    replyDraft.clear();
    replyCtrl.clear();
  }

  Future<void> sendFromBar() async {
    if (replyDraft.isActive) {
      await sendReply(replyDraft.parentCommentId!, replyDraft.messageForApi(replyCtrl.text));
    } else {
      await sendTopLevelReply();
    }
  }

  List<FeedNestedCommentData> nestedReplies() {
    final knownIds = replies.map((p) => p.postId).toSet();
    final ids = replies.map((p) => p.postId).toList();
    final parents = replies
        .map((p) => p.resolvedParentPostId(knownIds))
        .toList();
    final depths = depthByCommentId(ids: ids, parentIds: parents);
    return replies
        .map(
          (post) {
            final parentId = post.resolvedParentPostId(knownIds);
            final depth = depths[post.postId] ?? 0;
            final message = post.messagePlainText?.trim().isNotEmpty == true
                ? post.messagePlainText!.trim()
                : _stripHtml(post.messageParsed);
            return FeedNestedCommentData(
              id: post.postId,
              parentId: parentId,
              depthHint: depth,
              authorName:
                  post.author?.label ?? post.author?.username ?? '',
              avatarUrl: post.author?.avatarUrl,
              dateLabel: formatFeedCommentDate(post.postDate),
              message: message,
              messageHtml: post.messageParsed,
              likeCount: post.reactionScore,
              canReply: nestedCommentCanReply(depth),
              canLike: post.canReact,
              onLike: post.canReact
                  ? (reactionId) => reactToReply(post, reactionId: reactionId)
                  : null,
            );
          },
        )
        .toList();
  }

  Future<void> sendReply(int parentPostId, String message) async {
    final text = message.trim();
    if (text.isEmpty) return;
    final beforeIds = replies.map((p) => p.postId).toList();
    isSending.value = true;
    try {
      ForumPost? quoted;
      if (parentPostId > 0) {
        for (final post in replies) {
          if (post.postId == parentPostId) {
            quoted = post;
            break;
          }
        }
      }
      await _service.postReply(
        threadId: threadId,
        message: text,
        parentPostId: parentPostId,
        quotedPost: quoted,
      );
      replyDraft.clear();
      replyCtrl.clear();
      await load();
      highlightReplyId.value = detectNewNestedCommentId(
        previousIds: beforeIds,
        current: nestedReplies(),
        parentCommentId: parentPostId,
      );
    } on ForumException catch (e) {
      ForumReactGuard.notifyError(e.message);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendTopLevelReply() async {
    await sendReply(0, replyCtrl.text);
  }

  void focusReplies() {
    cancelReply();
    final ctx = repliesKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

String _stripHtml(String? html) {
  if (html == null) return '';
  return html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
