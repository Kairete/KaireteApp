import 'package:flutter/material.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';
import 'package:kairete/features/suggestions/services/suggestion_actions.dart';
import 'package:kairete/features/suggestions/services/suggestions_service.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_horizontal_rail.dart';

/// Marker inserito nelle liste feed (come AppWidgetStripMarker).
class SuggestionsRailMarker {
  const SuggestionsRailMarker({
    this.initialItems = const [],
    this.title = 'Follow',
  });

  final List<SuggestionItem> initialItems;
  final String title;
}

/// Rail stile Facebook: carica sempre i suggerimenti dall'API.
class SuggestionsFeedRail extends StatefulWidget {
  const SuggestionsFeedRail({
    super.key,
    required this.marker,
  });

  final SuggestionsRailMarker marker;

  @override
  State<SuggestionsFeedRail> createState() => _SuggestionsFeedRailState();
}

class _SuggestionsFeedRailState extends State<SuggestionsFeedRail> {
  List<SuggestionItem> _items = const [];
  final _actions = SuggestionActions();
  final _service = SuggestionsService.instance;
  final Set<String> _busy = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.marker.initialItems);
    _loading = _items.isEmpty;
    _load();
  }

  @override
  void didUpdateWidget(covariant SuggestionsFeedRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.marker != widget.marker &&
        widget.marker.initialItems.isNotEmpty &&
        _items.isEmpty) {
      _items = List.of(widget.marker.initialItems);
    }
  }

  String _key(SuggestionItem item) =>
      '${item.contentType}:${item.contentId}';

  Future<void> _load() async {
    try {
      final payload = await _service.fetch(context: 'app', limit: 12);
      if (!mounted) return;
      setState(() {
        _items = List.of(payload.suggestions);
        _loading = false;
        _error = _items.isEmpty
            ? 'Nessun suggerimento disponibile al momento.'
            : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_items.isEmpty) {
          _error = AppToast.mapApiError(e.toString());
        }
      });
    }
  }

  Future<void> _onAction(SuggestionItem item) async {
    final key = _key(item);
    setState(() => _busy.add(key));
    try {
      await _actions.perform(item);
      if (!mounted) return;
      setState(() => _items.removeWhere((e) => _key(e) == key));
      AppToast.success('${item.actionLabel}: ${item.title}');
      await _load();
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  Future<void> _onDismiss(SuggestionItem item) async {
    final key = _key(item);
    setState(() => _items.removeWhere((e) => _key(e) == key));
    try {
      await _service.dismiss(
        contentType: item.contentType,
        contentId: item.contentId,
      );
      await _load();
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.marker.title.trim().isNotEmpty
        ? widget.marker.title.trim()
        : 'Follow';

    late final Widget body;
    if (_loading && _items.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (_items.isEmpty) {
      if (_error == null) return const SizedBox.shrink();
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _error!,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      );
    } else {
      body = SuggestionsHorizontalRail(
        title: title,
        showTitle: false,
        items: _items,
        busyIds: _busy,
        onAction: _onAction,
        onDismiss: _onDismiss,
      );
    }

    // Stesso chrome delle card Pubblicità / post del feed.
    return FeedCardShell(
      header: FeedCardHeaderBar(
        child: Row(
          children: [
            Icon(
              Icons.person_add_alt_1_outlined,
              size: 18,
              color: AppTheme.brandPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 12),
        child: body,
      ),
      footer: const FeedCardHeaderBar(
        child: SizedBox(height: 4),
      ),
    );
  }
}
