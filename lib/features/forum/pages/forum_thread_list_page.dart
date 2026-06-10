import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/core/widgets/feed_refresh_button.dart';
import 'package:kairete/features/feed/widgets/content_watch_bar.dart';
import 'package:kairete/features/forum/controllers/forum_thread_list_controller.dart';
import 'package:kairete/features/forum/widgets/thread_feed_card.dart';
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

        return RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              controller.loadThreads(),
              controller.loadWatchState(),
            ]);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: controller.items.length + 1,
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
              final thread = controller.items[i - 1];
              return ThreadFeedCard(
                thread: thread,
                forumTitle: forumTitle,
                onOpen: () => controller.openDetail(thread),
                onComment: () => controller.openDetail(thread),
                onReact: (reactionId) =>
                    controller.react(thread, reactionId: reactionId),
                onAuthorTap: () =>
                    OmnifeedNavigation.openUserProfile(thread.author?.userId),
                onTagTap: TagFeedNavigation.openTag,
              );
            },
          ),
        );
      }),
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
