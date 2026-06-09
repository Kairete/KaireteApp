import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/controllers/blog_list_controller.dart';
import 'package:kairete/features/blog/widgets/blog_feed_card.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/feed/widgets/content_watch_bar.dart';

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
      if (controller.items.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (filterBlogId != null)
              Obx(
                () => ContentWatchBar(
                  isWatched: controller.isWatched.value,
                  isLoading: controller.watchLoading.value,
                  visible: controller.canWatch.value,
                  onTap: controller.toggleWatch,
                ),
              ),
            const Expanded(
              child: Center(child: Text('Nessun articolo del blog.')),
            ),
          ],
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            controller.loadEntries(),
            if (filterBlogId != null) controller.loadWatchState(),
          ]);
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: controller.items.length + (filterBlogId != null ? 1 : 0),
          itemBuilder: (_, i) {
            if (filterBlogId != null && i == 0) {
              return Obx(
                () => ContentWatchBar(
                  isWatched: controller.isWatched.value,
                  isLoading: controller.watchLoading.value,
                  visible: controller.canWatch.value,
                  onTap: controller.toggleWatch,
                ),
              );
            }
            final index = filterBlogId != null ? i - 1 : i;
            final entry = controller.items[index];
            return BlogFeedCard(
              entry: entry,
              onOpen: () => controller.openDetail(entry),
              onComment: () => controller.openDetail(entry),
              onReact: (reactionId) =>
                  controller.react(entry, reactionId: reactionId),
              onAuthorTap: () =>
                  OmnifeedNavigation.openUserProfile(entry.author?.userId),
              onBlogTap: () => controller.openBlogFilter(entry),
              onCategoryTap: () => controller.openCategoryFilter(entry),
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
