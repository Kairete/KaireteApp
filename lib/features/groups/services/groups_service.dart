import 'package:kairete/config/app_config.dart';
import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/groups/models/group_post.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/groups/models/group_post_comment.dart';
import 'package:kairete/features/groups/models/social_group.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

class GroupsService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<SocialGroupsPage> fetchGroups({int page = 1}) async {
    await AppApi.instance.applySession();
    if (AppConfig.isTenantApp && TenantScope.groupId > 0) {
      final group = await fetchGroup(TenantScope.groupId);
      return SocialGroupsPage(groups: [group]);
    }
    final json = await _api.get(
      ApiPaths.socialGroups,
      query: {'page': page, 'limit': 20},
    );
    _throwIfError(json);
    return SocialGroupsPage.fromJson(json);
  }

  Future<SocialGroup> fetchGroup(int groupId) async {
    await AppApi.instance.applySession();
    final json = await _api.get('${ApiPaths.socialGroups}$groupId/');
    _throwIfError(json);
    final raw = json['group'] as Map<String, dynamic>? ?? json;
    return SocialGroup.fromJson(raw);
  }

  Future<GroupPostsPage> fetchPosts(int groupId, {int page = 1}) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.socialGroups}$groupId/posts/',
      query: {'page': page, 'limit': 20},
    );
    _throwIfError(json);
    return GroupPostsPage.fromJson(json);
  }

  /// Post di gruppo scritti da [userId] (per feed profilo).
  /// L'API `group-posts/?user_id=` non esiste: si scandiscono i gruppi visibili.
  Future<List<OmnifeedItem>> fetchAuthoredFeedItems(
    int userId, {
    int maxGroups = 30,
    int maxPagesPerGroup = 2,
  }) async {
    await AppApi.instance.applySession();
    if (userId <= 0) return [];

    if (AppConfig.isTenantApp && TenantScope.groupId > 0) {
      return _fetchAuthoredPostsInGroup(
        groupId: TenantScope.groupId,
        userId: userId,
        maxPages: maxPagesPerGroup,
      );
    }

    final groups = await _groupsForAuthoredPostScan(maxGroups: maxGroups);
    if (groups.isEmpty) return [];

    final lists = await Future.wait(
      groups.map(
        (group) => _fetchAuthoredPostsInGroup(
          groupId: group.groupId,
          userId: userId,
          groupTitle: group.title,
          maxPages: maxPagesPerGroup,
        ),
      ),
    );
    return lists.expand((list) => list).toList();
  }

  Future<List<SocialGroup>> _groupsForAuthoredPostScan({
    required int maxGroups,
  }) async {
    final seen = <int>{};
    final groups = <SocialGroup>[];

    for (var page = 1; page <= 2; page++) {
      try {
        final batch = await fetchGroups(page: page);
        for (final group in batch.groups) {
          if (group.groupId <= 0 || !seen.add(group.groupId)) continue;
          if (group.postCount <= 0) continue;
          groups.add(group);
        }
        if (batch.groups.length < 20) break;
      } catch (_) {
        break;
      }
    }

    groups.sort((a, b) {
      final memberDelta = (b.isMember ? 1 : 0) - (a.isMember ? 1 : 0);
      if (memberDelta != 0) return memberDelta;
      return (b.lastPostDate ?? 0).compareTo(a.lastPostDate ?? 0);
    });

    return groups.take(maxGroups).toList();
  }

  Future<List<OmnifeedItem>> _fetchAuthoredPostsInGroup({
    required int groupId,
    required int userId,
    String? groupTitle,
    required int maxPages,
  }) async {
    if (groupId <= 0) return [];

    var title = groupTitle?.trim();
    if (title == null || title.isEmpty) {
      try {
        title = (await fetchGroup(groupId)).title;
      } catch (_) {
        title = '';
      }
    }

    final items = <OmnifeedItem>[];
    for (var page = 1; page <= maxPages; page++) {
      GroupPostsPage postsPage;
      try {
        postsPage = await fetchPosts(groupId, page: page);
      } catch (_) {
        break;
      }
      if (postsPage.posts.isEmpty) break;

      for (final post in postsPage.posts) {
        if (post.author?.userId != userId) continue;
        items.add(_groupPostToOmnifeedItem(post, groupTitle: title));
      }
      if (postsPage.posts.length < 20) break;
    }
    return items;
  }

  OmnifeedItem _groupPostToOmnifeedItem(
    GroupPost post, {
    required String? groupTitle,
  }) {
    final author = post.author;
    final title = groupTitle?.trim();
    return OmnifeedItem.fromGroupPostApi({
      'group_post_id': post.groupPostId,
      'group_id': post.groupId,
      'message_plain_text': post.messagePlainText,
      'post_date': post.postDate,
      'comment_count': post.commentCount,
      'reaction_score': post.reactionScore,
      'visitor_reaction_id': post.visitorReactionId,
      if (title != null && title.isNotEmpty)
        'Group': {
          'group_id': post.groupId,
          'title': title,
          'name': title,
        },
      if (author != null)
        'User': {
          'user_id': author.userId,
          'username': author.username,
          if (author.avatarUrl != null && author.avatarUrl!.isNotEmpty)
            'avatar_urls': {'m': author.avatarUrl},
        },
    });
  }

  Future<GroupPostCommentsPage> fetchComments(int groupPostId) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.groupPosts}$groupPostId/comments/',
    );
    _throwIfError(json);
    final page = GroupPostCommentsPage.fromJson(json);
    return GroupPostCommentsPage(comments: _enrichCommentParents(page.comments));
  }

  List<GroupPostComment> _enrichCommentParents(List<GroupPostComment> comments) {
    if (comments.isEmpty) return comments;
    final ids = comments.map((c) => c.commentId).toList();
    final parents = comments.map((c) => c.parentCommentId).toList();
    final messages = comments.map((c) => c.messagePlainText).toList();
    final enriched = FeedCommentParent.enrichParentIds(
      ids: ids,
      parentIds: parents,
      messages: messages,
    );
    final out = <GroupPostComment>[];
    for (var i = 0; i < comments.length; i++) {
      final parent = enriched[i];
      out.add(
        parent != comments[i].parentCommentId
            ? comments[i].withParentCommentId(parent)
            : comments[i],
      );
    }
    return out;
  }

  Future<void> createPost({
    required int groupId,
    required String message,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.socialGroups}$groupId/posts/',
      body: {'message': message},
    );
    _throwIfError(json);
  }

  Future<void> postComment({
    required int groupPostId,
    required String message,
    int parentCommentId = 0,
  }) async {
    await AppApi.instance.applySession();
    final body = <String, dynamic>{'message': message};
    if (parentCommentId > 0) {
      body['parent_comment_id'] = parentCommentId;
    }
    final json = await _api.post(
      '${ApiPaths.groupPosts}$groupPostId/comments/',
      body: body,
    );
    _throwIfError(json);
  }

  Future<void> joinGroup(int groupId) async {
    await AppApi.instance.applySession();
    final json = await _api.post('${ApiPaths.socialGroups}$groupId/join/');
    _throwIfError(json);
  }

  Future<void> leaveGroup(int groupId) async {
    await AppApi.instance.applySession();
    final json = await _api.post('${ApiPaths.socialGroups}$groupId/leave/');
    _throwIfError(json);
  }

  Future<void> deletePost(int groupPostId) async {
    await AppApi.instance.applySession();
    final json = await _api.delete('${ApiPaths.groupPosts}$groupPostId');
    _throwIfError(json);
  }

  Future<String> reactToPost({
    required int groupPostId,
    int? authorUserId,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactGroupPost(
        groupPostId,
        reactionId: reactionId,
      );
    } on ReactionException catch (e) {
      throw GroupsException(e.message);
    }
  }

  Future<String> reactToComment({
    required int commentId,
    int? authorUserId,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactGroupComment(
        commentId,
        authorUserId: authorUserId,
        reactionId: reactionId,
      );
    } on ReactionException catch (e) {
      throw GroupsException(e.message);
    }
  }

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw GroupsException(err);
  }
}

class GroupsException implements Exception {
  GroupsException(this.message);
  final String message;

  @override
  String toString() => message;
}
