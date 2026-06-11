import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/media/controllers/media_list_controller.dart';
import 'package:kairete/features/media/pages/album_create_page.dart';
import 'package:kairete/features/media/pages/media_compose_page.dart';
import 'package:kairete/features/media/widgets/media_action_bar.dart';
import 'package:kairete/features/media/widgets/media_feed_card.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class MediaListPage extends StatelessWidget {
  MediaListPage({
    super.key,
    this.filterAlbumId,
    this.filterCategoryId,
    this.pageTitle,
    this.showActionBar = true,
  });

  final int? filterAlbumId;
  final int? filterCategoryId;
  final String? pageTitle;
  final bool showActionBar;

  @override
  Widget build(BuildContext context) {
    final tag = 'media_${filterAlbumId ?? 0}_${filterCategoryId ?? 0}';
    if (!Get.isRegistered<MediaListController>(tag: tag)) {
      Get.put(
        MediaListController(
          filterAlbumId: filterAlbumId,
          filterCategoryId: filterCategoryId,
        ),
        tag: tag,
      );
    }
    final controller = Get.find<MediaListController>(tag: tag);
    final isFiltered = filterAlbumId != null || filterCategoryId != null;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showActionBar && !isFiltered)
          Obx(
            () => MediaActionBar(
              onTapRefresh: controller.refreshAll,
              onTapAddMedia: () async {
                final created = await Get.to<bool>(() => const MediaComposePage());
                if (created == true) await controller.refreshAll();
              },
              onTapCreateAlbum: () async {
                final created =
                    await Get.to<bool>(() => const AlbumCreatePage());
                if (created == true) await controller.refreshAll();
              },
              isRefreshing: controller.isLoading.value,
            ),
          ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.errorMessage.value.isNotEmpty &&
                controller.items.isEmpty) {
              return _ErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.loadMedia,
              );
            }
            if (controller.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: controller.refreshAll,
                child: ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.35,
                      child: const Center(child: Text('Nessun media.')),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.refreshAll,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: controller.items.length,
                itemBuilder: (_, i) {
                  final item = controller.items[i];
                  return MediaFeedCard(
                    item: item,
                    onOpen: () => controller.openDetail(item),
                    onComment: () => controller.openDetail(item),
                    onReact: (reactionId) =>
                        controller.react(item, reactionId: reactionId),
                    onAuthorTap: () => controller.openAuthorProfile(item),
                    onAlbumTap: () => controller.openAlbumFilter(item),
                    onCategoryTap: () => controller.openCategoryFilter(item),
                    onThumbnailTap: () => controller.openDetail(item),
                    onTagTap: TagFeedNavigation.openTag,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );

    if (!isFiltered) return body;

    return Scaffold(
      backgroundColor: AppTheme.feedFooterBg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(pageTitle ?? 'Media'),
        actions: [
          IconButton(
            tooltip: 'Aggiungi media',
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () async {
              final created = await Get.to<bool>(() => const MediaComposePage());
              if (created == true) await controller.refreshAll();
            },
          ),
          IconButton(
            tooltip: 'Crea album',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () async {
              final created = await Get.to<bool>(() => const AlbumCreatePage());
              if (created == true) await controller.refreshAll();
            },
          ),
        ],
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
