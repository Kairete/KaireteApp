import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/widgets/app_widget_strip.dart';
import 'package:kairete/features/feed/widgets/feed_inline_reply_host.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_feed_card_tile.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_content_filters.dart';

class OmnifeedPage extends StatelessWidget {
  const OmnifeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = OmnifeedController.ensure();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!AppConfig.isTenantApp)
          Obx(
            () => OmnifeedContentFilters(
              tabs: c.feedTabs.toList(),
              selectedModeIndex: c.feedModeIndex.value,
              sortMode: c.sortMode.value,
              onModeSelected: c.setFeedModeIndex,
              tabsReady: c.feedTabsReady.value,
              allowLegacyFallback: c.feedTabsApiFailed.value,
              showSortToggle: c.feedTabsApiFailed.value && c.feedTabs.isEmpty,
              onSortChanged:
                  c.feedTabsApiFailed.value && c.feedTabs.isEmpty
                      ? c.setSortMode
                      : null,
            ),
          ),
        Expanded(
          child: Obx(() {
            if (c.isLoading.value && c.items.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppTheme.brandPrimary),
              );
            }
            if (c.errorMessage.value.isNotEmpty && c.items.isEmpty) {
              return _ErrorState(
                message: c.errorMessage.value,
                onRetry: c.loadFeed,
              );
            }
            return RefreshIndicator(
              onRefresh: c.loadFeed,
              child: c.items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              c.emptyFeedHint.value.isNotEmpty
                                  ? c.emptyFeedHint.value
                                  : 'Nessun contenuto nel feed.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Builder(builder: (_) {
                      // Osserva payload widget del placement corrente.
                      c.appWidgetsPayload.value;
                      c.followedAuthorIds.length;
                      final slots = c.injectedSlots(c.items.toList());
                      final footer = c.hasMorePages.value ? 1 : 0;
                      return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: slots.length + footer,
                      itemBuilder: (_, i) {
                        if (i >= slots.length) {
                          if (!c.isLoadingMore.value) {
                            // ignore: discarded_futures
                            c.loadMoreFeed();
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: c.isLoadingMore.value
                                  ? CircularProgressIndicator(
                                      color: AppTheme.brandPrimary,
                                    )
                                  : const SizedBox(height: 24),
                            ),
                          );
                        }
                        final slot = slots[i];
                        // Confronti espliciti: dopo hot-reload `is` a volte fallisce.
                        if (slot is SuggestionsRailMarker ||
                            slot.runtimeType.toString() ==
                                'SuggestionsRailMarker') {
                          final marker = slot is SuggestionsRailMarker
                              ? slot
                              : const SuggestionsRailMarker();
                          return SuggestionsFeedRail(marker: marker);
                        }
                        if (slot is AppWidgetStripMarker) {
                          return AppWidgetStrip(widgets: slot.widgets);
                        }
                        if (slot is! OmnifeedItem) {
                          return const SizedBox.shrink();
                        }
                        final item = slot;
                        return OmnifeedFeedCardTile(
                          item: item,
                          controller: c,
                          onCommentsChanged: c.loadFeed,
                        );
                      },
                    );
                    }),
            );
          }),
        ),
        const FeedInlineReplyBar(),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}
