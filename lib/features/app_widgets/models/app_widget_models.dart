class AppWidgetCard {
  const AppWidgetCard({
    required this.widgetId,
    required this.title,
    this.subtitle = '',
    this.imageUrl = '',
    this.actionType = 'url',
    this.actionPayload = '',
    this.styleHint = 'card',
    this.widgetKind = 'card',
    this.htmlBody = '',
    this.suggestions = const [],
    this.placement = '',
    this.insertEvery = 5,
    this.insertOffset = 0,
    this.maxInserts = 3,
  });

  final int widgetId;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionType;
  final String actionPayload;
  final String styleHint;
  final String widgetKind;
  final String htmlBody;
  final List<Map<String, dynamic>> suggestions;
  final String placement;
  final int insertEvery;
  final int insertOffset;
  final int maxInserts;

  bool get isHtmlBlock =>
      widgetKind == 'html_block' && htmlBody.trim().isNotEmpty;

  bool get isSuggestions => widgetKind == 'suggestions';

  factory AppWidgetCard.fromJson(Map<String, dynamic> json) {
    final rawSuggestions = json['suggestions'];
    final suggestions = <Map<String, dynamic>>[];
    if (rawSuggestions is List) {
      for (final item in rawSuggestions) {
        if (item is Map) {
          suggestions.add(Map<String, dynamic>.from(item));
        }
      }
    }
    return AppWidgetCard(
      widgetId: (json['widget_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      subtitle: (json['subtitle'] as String?)?.trim() ?? '',
      imageUrl: (json['image_url'] as String?)?.trim() ?? '',
      actionType: (json['action_type'] as String?)?.trim() ?? 'url',
      actionPayload: (json['action_payload'] as String?)?.trim() ?? '',
      styleHint: (json['style_hint'] as String?)?.trim() ?? 'card',
      widgetKind: (json['widget_kind'] as String?)?.trim() ?? 'card',
      htmlBody: (json['html_body'] as String?)?.trim() ?? '',
      suggestions: suggestions,
      placement: (json['placement'] as String?)?.trim() ?? '',
      insertEvery:
          ((json['insert_every'] as num?)?.toInt() ?? 5).clamp(1, 100),
      insertOffset:
          ((json['insert_offset'] as num?)?.toInt() ?? 0).clamp(0, 100),
      maxInserts:
          ((json['max_inserts'] as num?)?.toInt() ?? 3).clamp(1, 50),
    );
  }
}

class AppWidgetRules {
  const AppWidgetRules({
    this.insertEvery = 5,
    this.offset = 0,
    this.maxInserts = 3,
  });

  final int insertEvery;
  final int offset;
  final int maxInserts;

  factory AppWidgetRules.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppWidgetRules();
    return AppWidgetRules(
      insertEvery: ((json['insert_every'] as num?)?.toInt() ?? 5).clamp(1, 100),
      offset: ((json['offset'] as num?)?.toInt() ?? 0).clamp(0, 100),
      maxInserts: ((json['max_inserts'] as num?)?.toInt() ?? 3).clamp(1, 50),
    );
  }
}

class AppWidgetPayload {
  const AppWidgetPayload({
    required this.widgets,
    required this.rules,
    this.schemaVersion = 1,
  });

  final List<AppWidgetCard> widgets;
  final AppWidgetRules rules;
  final int schemaVersion;

  bool get isEmpty => widgets.isEmpty;

  factory AppWidgetPayload.empty() => const AppWidgetPayload(
        widgets: [],
        rules: AppWidgetRules(),
      );

  factory AppWidgetPayload.fromJson(Map<String, dynamic> json) {
    final rawWidgets = json['widgets'];
    final widgets = <AppWidgetCard>[];
    if (rawWidgets is List) {
      for (final item in rawWidgets) {
        if (item is Map) {
          final card = AppWidgetCard.fromJson(Map<String, dynamic>.from(item));
          final usable = card.widgetId > 0 &&
              (card.title.isNotEmpty ||
                  card.isHtmlBlock ||
                  card.isSuggestions);
          if (usable) {
            widgets.add(card);
          }
        }
      }
    }
    final rulesRaw = json['rules'];
    return AppWidgetPayload(
      widgets: widgets,
      rules: AppWidgetRules.fromJson(
        rulesRaw is Map ? Map<String, dynamic>.from(rulesRaw) : null,
      ),
      schemaVersion: (json['schema_version'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Marker for a widget slot inside an injected list.
class AppWidgetStripMarker {
  const AppWidgetStripMarker(this.widgets);
  final List<AppWidgetCard> widgets;
}
