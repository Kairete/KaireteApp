import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/reaction_service.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';

class TagFeedService {
  XenforoApi get _api => AppApi.instance.xenforo;
  final ReactionService _reactions = ReactionService();

  Future<TagFeedPage> fetchByTag({
    required String tag,
    int page = 1,
    String sort = 'post_date',
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      ApiPaths.tagFeed,
      query: {
        'tag': _cleanTag(tag),
        'page': page,
        'sort': sort,
      },
    );
    _throwIfError(json);
    return TagFeedPage.fromJson(json);
  }

  Future<String> reactToItem({
    required OmnifeedItem item,
    int reactionId = 1,
  }) async {
    try {
      return await _reactions.reactOmnifeedItem(item, reactionId: reactionId);
    } on ReactionException catch (e) {
      throw OmnifeedException(e.message);
    }
  }

  String _cleanTag(String tag) =>
      tag.trim().replaceFirst(RegExp(r'^#'), '');

  void _throwIfError(Map<String, dynamic> json) {
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw OmnifeedException(err);
  }
}

class TagFeedPage {
  TagFeedPage({
    required this.items,
    required this.tagLabel,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  final List<OmnifeedItem> items;
  final String tagLabel;
  final int currentPage;
  final int lastPage;
  final int total;

  factory TagFeedPage.fromJson(Map<String, dynamic> json) {
    final raw = json['newsfeedItems'] as List<dynamic>? ?? [];
    final tag = json['tag'] as Map<String, dynamic>?;
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return TagFeedPage(
      items: raw
          .map((e) => OmnifeedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      tagLabel: tag?['tag']?.toString() ?? '',
      currentPage: pagination['current_page'] as int? ?? 1,
      lastPage: pagination['last_page'] as int? ?? 1,
      total: pagination['total'] as int? ?? raw.length,
    );
  }
}
