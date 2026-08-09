import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/feed_refresh_button.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/widgets/app_widget_strip.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/blog/widgets/blog_feed_card.dart';
import 'package:kairete/features/feed/widgets/content_watch_bar.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/forum/controllers/forum_thread_list_controller.dart';
import 'package:kairete/features/forum/models/forum_feed_item.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/forum/widgets/thread_feed_card.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class ForumThreadListPage extends StatelessWidget {
  ForumThreadListPage({
    super.key,
    required this.forumId,
    required this.forumTitle,
  });

  final int forumId;
  final String forumTitle;

  @override
  Widget build(BuildContext context) {
    final tag = 'forum_threads_$forumId';
    if (!Get.isRegistered<ForumThreadListController>(tag: tag)) {
      Get.put(
        ForumThreadListController(
          forumId: forumId,
          forumTitle: forumTitle,
        ),
        tag: tag,
      );
    }
    final controller = Get.find<ForumThreadListController>(tag: tag);

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(forumTitle),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FeedRefreshButton(
                compact: true,
                isLoading: controller.isLoading.value,
                onTap: controller.loadThreads,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Nuova discussione',
            icon: const Icon(Icons.edit_outlined),
            onPressed: controller.openCreate,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openCreate,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Discussione'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty &&
            controller.items.isEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.loadThreads,
          );
        }
        if (controller.items.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Obx(
                () => ContentWatchBar(
                  isWatched: controller.isWatched.value,
                  isLoading: controller.watchLoading.value,
                  visible: controller.canWatch.value,
                  onTap: controller.toggleWatch,
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Nessuna discussione in questo forum.'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: controller.openCreate,
                          icon: const Icon(Icons.add),
                          label: const Text('Avvia una discussione'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final slots = controller.injectedSlots(controller.items.toList());
        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.loadThreads(),
              controller.loadWatchState(),
            ]);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: slots.length + 1,
            itemBuilder: (_, i) {
              if (i == 0) {
                return Obx(
                  () => ContentWatchBar(
                    isWatched: controller.isWatched.value,
                    isLoading: controller.watchLoading.value,
                    visible: controller.canWatch.value,
                    onTap: controller.toggleWatch,
                  ),
                );
              }
              final slot = slots[i - 1];
              if (slot is SuggestionsRailMarker) {
                return SuggestionsFeedRail(marker: slot);
              }
              if (slot is AppWidgetStripMarker) {
                return AppWidgetStrip(widgets: slot.widgets);
              }
              final feedItem = slot as ForumFeedItem;
              final blog = feedItem.blogEntry;
              if (blog != null) {
                return _blogCard(context, controller, blog);
              }
              final thread = feedItem.thread!;
              return _threadCard(context, controller, thread);
            },
          ),
        );
      }),
    );
  }

  Widget _blogCard(
    BuildContext context,
    ForumThreadListController controller,
    BlogEntry entry,
  ) {
    return BlogFeedCard(
      entry: entry,
      onOpen: () => controller.openBlogDetail(entry),
      onComment: () => controller.openBlogDetail(entry),
      onReact: (reactionId) =>
          controller.reactBlog(entry, reactionId: reactionId),
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
    );
  }

  Widget _threadCard(
    BuildContext context,
    ForumThreadListController controller,
    ForumThread thread,
  ) {
    return ThreadFeedCard(
      thread: thread,
      forumTitle: forumTitle,
      onOpen: () => controller.openDetail(thread),
      onComment: () => controller.openDetail(thread),
      onReact: (reactionId) =>
          controller.react(thread, reactionId: reactionId),
      onShareInternal: () async {
        final result = await showFeedShareInternal(
          context: context,
          itemId: OmnifeedItemId.encode(
            OmnifeedItemId.typeThread,
            thread.threadId,
          ),
          previewText: thread.messagePlainText ?? thread.title,
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
            OmnifeedItemId.typeThread,
            thread.threadId,
          ),
          viewUrl: thread.viewUrl,
        );
      },
      onAuthorTap: () => OmnifeedNavigation.openUserProfile(
            thread.author?.userId,
            username: thread.author?.username,
          ),
      onTagTap: TagFeedNavigation.openTag,
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
