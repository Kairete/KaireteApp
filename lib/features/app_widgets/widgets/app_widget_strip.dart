import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_navigation.dart';
import 'package:kairete/features/feed/widgets/feed_card_widgets.dart';
import 'package:kairete/features/suggestions/models/suggestion_models.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget ACP inseriti nel feed: stesso chrome/larghezza delle card post.
class AppWidgetStrip extends StatelessWidget {
  const AppWidgetStrip({super.key, required this.widgets});

  final List<AppWidgetCard> widgets;

  @override
  Widget build(BuildContext context) {
    if (widgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final card in widgets)
          if (card.isSuggestions ||
              card.widgetKind == 'suggestions' ||
              card.suggestions.isNotEmpty)
            _SuggestionsAppWidget(card: card)
          else
            _AppWidgetFeedCard(card: card),
      ],
    );
  }
}

class _SuggestionsAppWidget extends StatefulWidget {
  const _SuggestionsAppWidget({required this.card});

  final AppWidgetCard card;

  @override
  State<_SuggestionsAppWidget> createState() => _SuggestionsAppWidgetState();
}

class _SuggestionsAppWidgetState extends State<_SuggestionsAppWidget> {
  @override
  Widget build(BuildContext context) {
    final seed = widget.card.suggestions
        .map(SuggestionItem.fromJson)
        .where((e) => e.contentId > 0 && e.title.isNotEmpty)
        .toList();
    final title = widget.card.title.trim();
    return SuggestionsFeedRail(
      marker: SuggestionsRailMarker(
        initialItems: seed,
        title: title.isNotEmpty ? title : 'Follow',
      ),
    );
  }
}

class _AppWidgetFeedCard extends StatelessWidget {
  const _AppWidgetFeedCard({required this.card});

  final AppWidgetCard card;

  @override
  Widget build(BuildContext context) {
    final tappable = card.actionType != 'none' &&
        card.actionPayload.trim().isNotEmpty &&
        !card.isHtmlBlock;

    final shell = FeedCardShell(
      header: FeedCardHeaderBar(
        child: Row(
          children: [
            Icon(
              card.isHtmlBlock ? Icons.code : Icons.campaign_outlined,
              size: 18,
              color: AppTheme.brandPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                card.title.isNotEmpty ? card.title : 'In evidenza',
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
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: card.isHtmlBlock
            ? _HtmlBody(html: card.htmlBody)
            : _PromoBody(card: card),
      ),
      footer: const FeedCardHeaderBar(
        child: SizedBox(height: 4),
      ),
    );

    if (!tappable) return shell;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppWidgetNavigation.open(card),
        child: shell,
      ),
    );
  }
}

class _HtmlBody extends StatelessWidget {
  const _HtmlBody({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    return Html(
      data: html,
      style: {
        'body': Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          lineHeight: const LineHeight(1.35),
          color: AppTheme.textPrimary,
        ),
        'p': Style(
          margin: Margins.only(bottom: 6),
          padding: HtmlPaddings.zero,
        ),
        'a': Style(color: AppTheme.linkBlue),
      },
      onLinkTap: (url, _, __) async {
        if (url == null || url.isEmpty) return;
        final uri = Uri.tryParse(url);
        if (uri == null) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
    );
  }
}

class _PromoBody extends StatelessWidget {
  const _PromoBody({required this.card});

  final AppWidgetCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (card.imageUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                card.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (card.subtitle.isNotEmpty)
          Text(
            card.subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppTheme.textPrimary,
            ),
          )
        else if (card.imageUrl.isEmpty)
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              color: AppTheme.textPrimary,
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppTheme.feedItemChromeBg,
      child: Center(
        child: Icon(
          Icons.campaign_outlined,
          size: 36,
          color: AppTheme.brandPrimary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
