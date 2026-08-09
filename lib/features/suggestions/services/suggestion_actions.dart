import 'package:kairete/features/blog/services/blog_service.dart';
import 'package:kairete/features/forum/services/forum_service.dart';
import 'package:kairete/features/groups/services/groups_service.dart';
import 'package:kairete/features/media/services/media_service.dart';
import 'package:kairete/features/profile/services/profile_service.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';

/// Esegue follow / watch / join sul target del suggerimento.
class SuggestionActions {
  SuggestionActions({
    ProfileService? profile,
    BlogService? blog,
    ForumService? forum,
    MediaService? media,
    GroupsService? groups,
  })  : _profile = profile ?? ProfileService(),
        _blog = blog ?? BlogService(),
        _forum = forum ?? ForumService(),
        _media = media ?? MediaService(),
        _groups = groups ?? GroupsService();

  final ProfileService _profile;
  final BlogService _blog;
  final ForumService _forum;
  final MediaService _media;
  final GroupsService _groups;

  Future<void> perform(SuggestionItem item) async {
    switch (item.contentType) {
      case 'user':
        await _profile.followUser(item.contentId, stop: false);
        break;
      case 'blog':
        await _blog.watchBlog(item.contentId, stop: false);
        break;
      case 'forum':
        await _forum.watchForum(item.contentId, stop: false);
        break;
      case 'album':
        await _media.watchAlbum(item.contentId, stop: false);
        break;
      case 'group':
        await _groups.joinGroup(item.contentId);
        break;
      default:
        throw StateError('Tipo non supportato: ${item.contentType}');
    }
  }
}
