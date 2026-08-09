import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/widgets/app_widget_strip.dart';
import 'package:kairete/features/blog/controllers/blog_list_controller.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/widgets/blog_cover_header.dart';
import 'package:kairete/features/blog/widgets/blog_feed_card.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class BlogListPage extends StatelessWidget {
  BlogListPage({
    super.key,
    this.filterBlogId,
    this.filterCategoryId,
    this.pageTitle,
  });

  final int? filterBlogId;
  final int? filterCategoryId;
  final String? pageTitle;

  @override
  Widget build(BuildContext context) {
    final tag = 'blog_${filterBlogId ?? 0}_${filterCategoryId ?? 0}';
    if (!Get.isRegistered<BlogListController>(tag: tag)) {
      Get.put(
        BlogListController(
          filterBlogId: filterBlogId,
          filterCategoryId: filterCategoryId,
        ),
        tag: tag,
      );
    }
    final controller = Get.find<BlogListController>(tag: tag);
    final isFiltered = filterBlogId != null || filterCategoryId != null;

    final body = Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorMessage.value.isNotEmpty &&
          controller.items.isEmpty) {
        return _ErrorState(
          message: controller.errorMessage.value,
          onRetry: controller.loadEntries,
        );
      }

      final profile = controller.blogProfile.value;
      final showCover = filterBlogId != null && profile != null;
      final headerCount = showCover ? 1 : 0;

      Widget coverHeader() => BlogCoverHeader(
            profile: profile!,
            isWatched: controller.isWatched.value,
            watchLoading: controller.watchLoading.value,
            canWatch: controller.canWatch.value,
            onWatchTap: controller.toggleWatch,
          );

      if (controller.items.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            children: [
              if (showCover) coverHeader(),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: const Center(child: Text('Nessun articolo del blog.')),
              ),
            ],
          ),
        );
      }

      final slots = controller.injectedSlots(controller.items.toList());
      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: slots.length + headerCount,
          itemBuilder: (_, i) {
            if (showCover && i == 0) return coverHeader();
            final slot = slots[i - headerCount];
            if (slot is SuggestionsRailMarker) {
              return SuggestionsFeedRail(marker: slot);
            }
            if (slot is AppWidgetStripMarker) {
              return AppWidgetStrip(widgets: slot.widgets);
            }
            final entry = slot as BlogEntry;
            return BlogFeedCard(
              entry: entry,
              onOpen: () => controller.openDetail(entry),
              onComment: () => controller.openDetail(entry),
              onReact: (reactionId) =>
                  controller.react(entry, reactionId: reactionId),
              onShareInternal: () async {
                final result = await showFeedShareInternal(
                  context: context,
                  itemId: OmnifeedItemId.encode(
                    OmnifeedItemId.typeBlogPost,
                    entry.blogEntryId,
                  ),
                  previewText: entry.messagePlainText ?? entry.title,
                );
                final created = result?.createdItem;
                if (created != null) {
                  OmnifeedController.ensure().prependItem(created);
                }
              },
              onShareExternal: () async {
                await showFeedShareExternal(
                  context: context,
                  itemId: OmnifeedItemId.encode(
                    OmnifeedItemId.typeBlogPost,
                    entry.blogEntryId,
                  ),
                  viewUrl: entry.viewUrl,
                );
              },
              onAuthorTap: () => OmnifeedNavigation.openUserProfile(
                    entry.author?.userId,
                    username: entry.author?.username,
                  ),
              onBlogTap: () => controller.openBlogFilter(entry),
              onTagTap: TagFeedNavigation.openTag,
              showOwnerActions: entry.canEdit ||
                  entry.canDelete ||
                  entry.canHighlight ||
                  entry.isHighlighted,
              onEdit: entry.canEdit ? () => controller.editEntry(entry) : null,
              onDelete:
                  entry.canDelete ? () => controller.deleteEntry(entry) : null,
              onHighlight: (entry.canHighlight || entry.isHighlighted)
                  ? () => controller.toggleHighlight(entry)
                  : null,
            );
          },
        ),
      );
    });

    if (!isFiltered) return body;

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(pageTitle ?? 'Blog'),
      ),
      body: body,
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
