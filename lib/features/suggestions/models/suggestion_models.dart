class SuggestionItem {
  const SuggestionItem({
    required this.contentType,
    required this.contentId,
    required this.title,
    this.subtitle = '',
    this.avatarUrl = '',
    this.action = 'follow',
    this.actionLabel = 'Segui',
    this.score = 0,
    this.meta = const {},
  });

  final String contentType;
  final int contentId;
  final String title;
  final String subtitle;
  final String avatarUrl;
  final String action;
  final String actionLabel;
  final double score;
  final Map<String, dynamic> meta;

  factory SuggestionItem.fromJson(Map<String, dynamic> json) {
    final metaRaw = json['meta'];
    return SuggestionItem(
      contentType: (json['content_type'] as String?)?.trim() ?? 'user',
      contentId: (json['content_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      subtitle: (json['subtitle'] as String?)?.trim() ?? '',
      avatarUrl: (json['avatar_url'] as String?)?.trim() ?? '',
      action: (json['action'] as String?)?.trim() ?? 'follow',
      actionLabel: (json['action_label'] as String?)?.trim() ?? 'Segui',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      meta: metaRaw is Map
          ? Map<String, dynamic>.from(metaRaw)
          : const <String, dynamic>{},
    );
  }
}

class SuggestionsPayload {
  const SuggestionsPayload({
    required this.suggestions,
    this.page = 1,
    this.perPage = 10,
    this.hasMore = false,
    this.method = 'smart',
    this.context = 'app',
    this.contentTypes = const [],
    this.enabled = true,
    this.schemaVersion = 1,
  });

  final List<SuggestionItem> suggestions;
  final int page;
  final int perPage;
  final bool hasMore;
  final String method;
  final String context;
  final List<String> contentTypes;
  final bool enabled;
  final int schemaVersion;

  bool get isEmpty => suggestions.isEmpty;

  factory SuggestionsPayload.empty() => const SuggestionsPayload(
        suggestions: [],
        enabled: false,
      );

  factory SuggestionsPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['suggestions'];
    final items = <SuggestionItem>[];
    if (raw is List) {
      for (final entry in raw) {
        if (entry is Map) {
          final item = SuggestionItem.fromJson(Map<String, dynamic>.from(entry));
          if (item.contentId > 0 && item.title.isNotEmpty) {
            items.add(item);
          }
        }
      }
    }
    final pagination = json['pagination'];
    final pageMap =
        pagination is Map ? Map<String, dynamic>.from(pagination) : null;
    final typesRaw = json['content_types'];
    final types = <String>[];
    if (typesRaw is List) {
      for (final t in typesRaw) {
        final s = t?.toString().trim() ?? '';
        if (s.isNotEmpty) types.add(s);
      }
    }

    return SuggestionsPayload(
      suggestions: items,
      page: (pageMap?['page'] as num?)?.toInt() ?? 1,
      perPage: (pageMap?['per_page'] as num?)?.toInt() ?? items.length,
      hasMore: pageMap?['has_more'] == true,
      method: (json['method'] as String?)?.trim() ?? 'smart',
      context: (json['context'] as String?)?.trim() ?? 'app',
      contentTypes: types,
      enabled: json['enabled'] != false,
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
    );
  }
}
