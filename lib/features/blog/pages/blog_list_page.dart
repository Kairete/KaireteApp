import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/blog/controllers/blog_list_controller.dart';
import 'package:kairete/features/blog/widgets/blog_cover_header.dart';
import 'package:kairete/features/blog/widgets/blog_feed_card.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';
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

      final profile = controller.blogProfile.value;
      final showCover = filterBlogId != null && profile != null;
      final showWatch = filterBlogId != null;
      final headerCount = (showCover ? 1 : 0) + (showWatch ? 1 : 0);

      if (controller.items.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView(
            children: [
              if (showCover) BlogCoverHeader(profile: profile!),
              if (showWatch)
                ContentWatchBar(
                  isWatched: controller.isWatched.value,
                  isLoading: controller.watchLoading.value,
                  visible: controller.canWatch.value,
                  onTap: controller.toggleWatch,
                ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: const Center(child: Text('Nessun articolo del blog.')),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: controller.items.length + headerCount,
          itemBuilder: (_, i) {
            var offset = 0;
            if (showCover) {
              if (i == 0) return BlogCoverHeader(profile: profile!);
              offset++;
            }
            if (showWatch) {
              if (i == offset) {
                return ContentWatchBar(
                  isWatched: controller.isWatched.value,
                  isLoading: controller.watchLoading.value,
                  visible: controller.canWatch.value,
                  onTap: controller.toggleWatch,
                );
              }
              offset++;
            }
            final entry = controller.items[i - offset];
            return BlogFeedCard(
              entry: entry,
              onOpen: () => controller.openDetail(entry),
              onComment: () => controller.openDetail(entry),
              onReact: (reactionId) =>
                  controller.react(entry, reactionId: reactionId),
              onAuthorTap: () =>
                  OmnifeedNavigation.openUserProfile(entry.author?.userId),
              onBlogTap: () => controller.openBlogFilter(entry),
              onTagTap: TagFeedNavigation.openTag,
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
