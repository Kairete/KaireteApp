import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';

class ReactionService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<String> reactToPost(int postId, {int reactionId = 1}) async {
    await _ensureLoggedIn();
    if (postId <= 0) {
      throw ReactionException('Post non disponibile.');
    }
    return _postReact('${ApiPaths.posts}$postId/react', reactionId);
  }

  Future<String> reactOmnifeedItem(
    OmnifeedItem item, {
    int reactionId = 1,
  }) async {
    await _ensureLoggedIn(authorUserId: item.author?.userId);
    final contentId = item.contentId;
    if (contentId == null || contentId <= 0) {
      throw ReactionException('Contenuto non disponibile.');
    }

    switch (item.contentType) {
      case 'profile_post':
        return _postReact('${ApiPaths.profilePosts}/$contentId/react', reactionId);
      case 'thread':
        final postId = await _threadFirstPostId(contentId);
        return reactToPost(postId, reactionId: reactionId);
      case 'ubs_blog_entry':
        return reactBlogEntry(
          contentId,
          authorUserId: item.author?.userId,
          reactionId: reactionId,
        );
      case 'tl_group_post':
        return _postReact('${ApiPaths.groupPosts}$contentId/react', reactionId);
      case 'ksg_group_post':
        return _postReact('${ApiPaths.groupPosts}$contentId/react', reactionId);
      default:
        throw ReactionException(
          'Reazione non supportata per ${item.typeLabel}.',
        );
    }
  }

  Future<String> reactBlogEntry(
    int blogEntryId, {
    int? authorUserId,
    int reactionId = 1,
  }) async {
    await _ensureLoggedIn(authorUserId: authorUserId);
    if (blogEntryId <= 0) {
      throw ReactionException('Articolo blog non disponibile.');
    }

    final paths = [
      '${ApiPaths.blogEntries}/$blogEntryId/react/',
      '${ApiPaths.blogEntries}/$blogEntryId/react',
    ];
    for (final path in paths) {
      final json = await _api.post(path, body: {'reaction_id': reactionId});
      final err = XenforoApi.firstErrorMessage(json);
      if (err == null) {
        return json['action']?.toString() ?? 'insert';
      }
      if (!_isRouteMissing(err)) {
        throw ReactionException(err);
      }
    }

    final json = await _api.post(
      ApiPaths.blogEntries,
      body: {
        'blog_entry_id': blogEntryId,
        'reaction_id': reactionId,
      },
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err == null) {
      return json['action']?.toString() ?? 'insert';
    }
    throw ReactionException(
      'Reazione blog non disponibile. Aggiorna l\'add-on Blog sul server.',
    );
  }

  Future<String> reactBlogComment(
    int commentId, {
    int? authorUserId,
    int reactionId = 1,
  }) async {
    await _ensureLoggedIn(authorUserId: authorUserId);
    if (commentId <= 0) {
      throw ReactionException('Commento non disponibile.');
    }
    return _postReact(
      '${ApiPaths.blogEntryComments}$commentId/react/',
      reactionId,
    );
  }

  Future<String> reactGroupPost(int groupPostId, {int reactionId = 1}) async {
    await _ensureLoggedIn();
    if (groupPostId <= 0) {
      throw ReactionException('Post gruppo non disponibile.');
    }
    return _postReact('${ApiPaths.groupPosts}$groupPostId/react', reactionId);
  }

  Future<String> reactGroupComment(
    int commentId, {
    int? authorUserId,
    int reactionId = 1,
  }) async {
    await _ensureLoggedIn(authorUserId: authorUserId);
    if (commentId <= 0) {
      throw ReactionException('Commento non disponibile.');
    }
    return _postReact(
      '${ApiPaths.groupComments}$commentId/react',
      reactionId,
    );
  }

  Future<void> _ensureLoggedIn({int? authorUserId}) async {
    await AppApi.instance.applySession();
    final userId = await AppApi.instance.sessionUserId;
    if (userId == null || userId <= 0) {
      throw ReactionException('Accedi per reagire.');
    }
    if (authorUserId != null &&
        authorUserId > 0 &&
        authorUserId == userId) {
      throw ReactionException('Non puoi reagire ai tuoi contenuti.');
    }
  }

  Future<int> _threadFirstPostId(int threadId) async {
    final json = await _api.get('${ApiPaths.threads}/$threadId');
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw ReactionException(err);
    final raw = json['thread'] as Map<String, dynamic>? ?? json;
    final postId = raw['first_post_id'] as int? ?? 0;
    if (postId <= 0) {
      throw ReactionException('Discussione non disponibile.');
    }
    return postId;
  }

  Future<String> _postReact(String path, int reactionId) async {
    var json = await _api.post(path, body: {'reaction_id': reactionId});
    var err = XenforoApi.firstErrorMessage(json);
    if (err == null) {
      return json['action']?.toString() ?? 'insert';
    }

    final alt = path.endsWith('/') ? path.substring(0, path.length - 1) : '$path/';
    json = await _api.post(alt, body: {'reaction_id': reactionId});
    err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw ReactionException(err);
    return json['action']?.toString() ?? 'insert';
  }

  bool _isRouteMissing(String message) {
    final lower = message.toLowerCase();
    return lower.contains('endpoint') ||
        lower.contains('cannot be found') ||
        lower.contains('invalid_route') ||
        lower.contains('invalid_action');
  }
}

class ReactionException implements Exception {
  ReactionException(this.message);
  final String message;

  @override
  String toString() => message;
}
