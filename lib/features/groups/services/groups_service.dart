import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/groups/models/group_post.dart';
import 'package:kairete/features/groups/models/group_post_comment.dart';
import 'package:kairete/features/groups/models/social_group.dart';

class GroupsService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<SocialGroupsPage> fetchGroups({int page = 1}) async {
    await AppApi.instance.applySession();
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

  Future<GroupPostCommentsPage> fetchComments(int groupPostId) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.groupPosts}$groupPostId/comments/',
    );
    _throwIfError(json);
    return GroupPostCommentsPage.fromJson(json);
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
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.post(
      '${ApiPaths.groupPosts}$groupPostId/comments/',
      body: {'message': message},
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
