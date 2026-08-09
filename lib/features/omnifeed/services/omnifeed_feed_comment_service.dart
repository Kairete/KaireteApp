import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/blog/models/blog_comment.dart';
import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
import 'package:kairete/features/groups/models/group_post_comment.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/media/models/media_comment.dart';
import 'package:kairete/features/media/utils/media_comment_ui.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_comment_ui.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

/// Carica e invia commenti inline per le card del newsfeed.
class OmnifeedFeedCommentService {
  OmnifeedFeedCommentService({
    OmnifeedService? omnifeedService,
    BlogService? blogService,
    ForumService? forumService,
    MediaService? mediaService,
    GroupsService? groupsService,
    ReactionService? reactionService,
  })  : _omnifeed = omnifeedService ?? OmnifeedService(),
        _blog = blogService ?? BlogService(),
        _forum = forumService ?? ForumService(),
        _media = mediaService ?? MediaService(),
        _groups = groupsService ?? GroupsService(),
        _reactions = reactionService ?? ReactionService();

  final OmnifeedService _omnifeed;
  final BlogService _blog;
  final ForumService _forum;
  final MediaService _media;
  final GroupsService _groups;
  final ReactionService _reactions;

  Future<List<FeedNestedCommentData>> load(OmnifeedItem item) async {
    final type = item.resolvedContentType;
    final nativeId = item.nativeContentId;
    if (nativeId <= 0 && item.itemId <= 0) return const [];

    final List<FeedNestedCommentData> mapped;
    switch (type) {
      case 'profile_post':
        final feedItemId = _feedItemId(item);
        if (feedItemId <= 0) return const [];
        final page = await _omnifeed.fetchComments(
          feedItemId,
          profilePostId: nativeId > 0 ? nativeId : null,
        );
        mapped = mapOmnifeedCommentsToNested(page.comments);
        break;
      case 'social_news_article':
        final feedItemId = item.itemId;
        final nativeId = item.nativeContentId;
        OmnifeedCommentsPage page = OmnifeedCommentsPage(comments: const []);
        if (feedItemId > 0) {
          try {
            page = await _omnifeed.fetchComments(feedItemId);
          } on OmnifeedException {
            page = OmnifeedCommentsPage(comments: const []);
          }
        }
        if (page.comments.isEmpty && nativeId > 0) {
          try {
            page = await _omnifeed.fetchSocialNewsArticleComments(nativeId);
          } on OmnifeedException {
            rethrow;
          }
        }
        mapped = mapOmnifeedCommentsToNested(page.comments);
        break;
      case 'ubs_blog_entry':
        final page = await _blog.fetchComments(nativeId);
        mapped = _mapBlogComments(enrichBlogCommentParents(page.comments));
        break;
      case 'thread':
        mapped = await _loadForumReplies(nativeId);
        break;
      case 'xfmg_media':
        final page = await _media.fetchComments(nativeId);
        mapped = _mapMediaComments(page.comments);
        break;
      case 'tl_group_post':
        final page = await _groups.fetchComments(nativeId);
        mapped = _mapGroupComments(page.comments);
        break;
      default:
        return const [];
    }
    return attachFeedCommentLikeHandlers(mapped, item);
  }

  /// Reazione su un commento/risposta inline della card feed.
  Future<String> reactComment({
    required OmnifeedItem item,
    required int commentId,
    int reactionId = 1,
    int? authorUserId,
  }) async {
    if (commentId <= 0) {
      throw ReactionException('Commento non disponibile.');
    }
    switch (item.resolvedContentType) {
      case 'profile_post':
        return _reactions.reactProfilePostComment(
          commentId,
          authorUserId: authorUserId,
          reactionId: reactionId,
        );
      case 'social_news_article':
        return _reactions.reactProfilePostComment(
          commentId,
          authorUserId: authorUserId,
          reactionId: reactionId,
        );
      case 'ubs_blog_entry':
        return _reactions.reactBlogComment(
          commentId,
          authorUserId: authorUserId,
          reactionId: reactionId,
        );
      case 'thread':
        return _reactions.reactToPost(commentId, reactionId: reactionId);
      case 'xfmg_media':
        return _reactions.reactMediaComment(
          commentId,
          authorUserId: authorUserId,
          reactionId: reactionId,
        );
      case 'tl_group_post':
        return _reactions.reactGroupComment(
          commentId,
          authorUserId: authorUserId,
          reactionId: reactionId,
        );
      default:
        throw ReactionException('Reazione commento non supportata.');
    }
  }

  List<FeedNestedCommentData> attachFeedCommentLikeHandlers(
    List<FeedNestedCommentData> comments,
    OmnifeedItem item,
  ) {
    if (comments.isEmpty) return comments;
    return [
      for (final comment in comments)
        comment.copyWith(
          onLike: comment.canLike
              ? (reactionId) => reactComment(
                    item: item,
                    commentId: comment.id,
                    reactionId: reactionId,
                  )
              : null,
          clearOnLike: !comment.canLike,
        ),
    ];
  }

  Future<void> post({
    required OmnifeedItem item,
    required String message,
    int parentCommentId = 0,
    int parentPostId = 0,
    ForumPost? quotedPost,
    String? quotedAuthorName,
    int quotedAuthorUserId = 0,
  }) async {
    final type = item.resolvedContentType;
    final nativeId = item.nativeContentId;
    final text = message.trim();
    if (text.isEmpty) return;

    switch (type) {
      case 'profile_post':
        final feedItemId = _feedItemId(item);
        if (feedItemId <= 0) return;
        await _omnifeed.postComment(
          itemId: feedItemId,
          message: text,
          parentCommentId: parentCommentId,
        );
        return;
      case 'social_news_article':
        if (item.itemId <= 0) return;
        await _omnifeed.postComment(
          itemId: item.itemId,
          message: text,
          parentCommentId: parentCommentId,
        );
        return;
      case 'ubs_blog_entry':
        await _blog.postComment(
          blogEntryId: nativeId,
          message: text,
          parentCommentId: parentCommentId,
        );
        return;
      case 'thread':
        await _forum.postReply(
          threadId: nativeId,
          message: text,
          parentPostId: parentPostId,
          quotedPost: quotedPost,
        );
        return;
      case 'xfmg_media':
        await _media.postComment(
          mediaId: nativeId,
          message: text,
          parentCommentId: parentCommentId,
          quotedAuthorName: quotedAuthorName,
          quotedAuthorUserId: quotedAuthorUserId,
        );
        return;
      case 'tl_group_post':
        await _groups.postComment(
          groupPostId: nativeId,
          message: text,
          parentCommentId: parentCommentId,
        );
        return;
    }
  }

  Future<List<FeedNestedCommentData>> _loadForumReplies(int threadId) async {
    final page = await _forum.fetchPostsPage(threadId, page: 1);
    final replies =
        page.posts.where((post) => !post.isFirstPost).toList(growable: false);
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
            final plain = post.messagePlainText?.trim().isNotEmpty == true
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
              message: plain,
              messageHtml: post.messageParsed,
              likeCount: post.reactionScore,
              canReply: nestedCommentCanReply(depth),
              canLike: post.canReact,
            );
          },
        )
        .toList();
  }

  List<FeedNestedCommentData> _mapBlogComments(List<BlogComment> comments) {
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
              authorName:
                  comment.author?.label ?? comment.author?.username ?? '',
              avatarUrl: comment.author?.avatarUrl,
              dateLabel: formatFeedCommentDate(comment.commentDate),
              message: comment.messagePlainText,
              messageHtml: comment.messageParsed,
              likeCount: comment.reactionScore,
              visitorReactionId: comment.visitorReactionId,
              canReply: nestedCommentCanReply(depth),
              canLike: comment.canReact,
            );
          },
        )
        .toList();
  }

  List<FeedNestedCommentData> _mapMediaComments(List<MediaComment> comments) {
    return mapMediaCommentsToNested(comments);
  }

  List<FeedNestedCommentData> _mapGroupComments(
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
            );
          },
        )
        .toList();
  }

  int _feedItemId(OmnifeedItem item) {
    if (item.itemId > 0) return item.itemId;
    final nativeId = item.nativeContentId;
    if (nativeId <= 0) return 0;
    return OmnifeedItemId.encode(
      OmnifeedItemId.typeProfilePost,
      nativeId,
    );
  }
}

Future<void> postForumFeedReply({
  required ForumService forum,
  required int threadId,
  required int parentPostId,
  required String message,
}) async {
  ForumPost? quoted;
  if (parentPostId > 0) {
    final page = await forum.fetchPostsPage(threadId, page: 1);
    for (final post in page.posts) {
      if (post.postId == parentPostId) {
        quoted = post;
        break;
      }
    }
  }
  await forum.postReply(
    threadId: threadId,
    message: message,
    parentPostId: parentPostId,
    quotedPost: quoted,
  );
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

/// Arricchisce commenti blog nel feed se manca il parent id.
List<BlogComment> enrichBlogCommentParents(List<BlogComment> comments) {
  if (comments.isEmpty) return comments;
  final ids = comments.map((c) => c.commentId).toList();
  final parents = comments.map((c) => c.parentCommentId).toList();
  final messages = comments.map((c) => c.messagePlainText).toList();
  final enriched = FeedCommentParent.enrichParentIds(
    ids: ids,
    parentIds: parents,
    messages: messages,
  );
  final out = <BlogComment>[];
  for (var i = 0; i < comments.length; i++) {
    final parent = enriched[i];
    if (parent != comments[i].parentCommentId) {
      out.add(BlogComment(
        commentId: comments[i].commentId,
        messagePlainText: comments[i].messagePlainText,
        parentCommentId: parent,
        messageParsed: comments[i].messageParsed,
        commentDate: comments[i].commentDate,
        reactionScore: comments[i].reactionScore,
        canReact: comments[i].canReact,
        visitorReactionId: comments[i].visitorReactionId,
        author: comments[i].author,
      ));
    } else {
      out.add(comments[i]);
    }
  }
  return out;
}
