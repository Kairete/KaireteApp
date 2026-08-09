import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';

/// Inietta i widget ACP nella lista rispettando placement + regole per-widget.
class AppWidgetInjector {
  AppWidgetInjector._();

  static List<Object> inject<T>(
    List<T> items,
    AppWidgetPayload? payload, {
    @Deprecated('Suggestions solo se presenti nel payload di questo placement')
    SuggestionsPayload? suggestions,
  }) {
    if (items.isEmpty) {
      return const [];
    }
    if (payload == null || payload.isEmpty) {
      return List<Object>.from(items);
    }

    final schedulable = <AppWidgetCard>[];
    for (final card in payload.widgets) {
      if (card.isSuggestions) {
        schedulable.add(card);
        continue;
      }
      if (_isBlankPromoCard(card)) continue;
      schedulable.add(card);
    }
    if (schedulable.isEmpty) {
      return List<Object>.from(items);
    }

    final insertCounts = <int, int>{
      for (final w in schedulable) w.widgetId: 0,
    };

    final out = <Object>[];
    var contentCount = 0;

    for (final item in items) {
      out.add(item as Object);
      contentCount++;

      for (final widget in schedulable) {
        final used = insertCounts[widget.widgetId] ?? 0;
        if (used >= widget.maxInserts) continue;
        if (contentCount <= widget.insertOffset) continue;
        if ((contentCount - widget.insertOffset) % widget.insertEvery != 0) {
          continue;
        }
        out.add(_markerFor(widget));
        insertCounts[widget.widgetId] = used + 1;
      }
    }

    return out;
  }

  static Object _markerFor(AppWidgetCard card) {
    if (card.isSuggestions) {
      final seed = <SuggestionItem>[];
      for (final raw in card.suggestions) {
        final item = SuggestionItem.fromJson(raw);
        if (item.contentId > 0 && item.title.isNotEmpty) {
          seed.add(item);
        }
      }
      final title = card.title.trim();
      return SuggestionsRailMarker(
        initialItems: seed,
        title: title.isNotEmpty ? title : 'Follow',
      );
    }
    return AppWidgetStripMarker([card]);
  }

  static bool _isBlankPromoCard(AppWidgetCard card) {
    if (card.isHtmlBlock) return false;
    if (card.imageUrl.trim().isNotEmpty) return false;
    if (card.subtitle.trim().isNotEmpty) return false;
    return card.title.trim().isEmpty;
  }

  /// Maps a display index into content index, or null if that slot is a strip.
  static int? contentIndexAt(List<Object> slots, int displayIndex) {
    if (displayIndex < 0 || displayIndex >= slots.length) return null;
    final slot = slots[displayIndex];
    if (slot is AppWidgetStripMarker || slot is SuggestionsRailMarker) {
      return null;
    }
    var contentIndex = 0;
    for (var i = 0; i < displayIndex; i++) {
      if (slots[i] is! AppWidgetStripMarker &&
          slots[i] is! SuggestionsRailMarker) {
        contentIndex++;
      }
    }
    return contentIndex;
  }
}
