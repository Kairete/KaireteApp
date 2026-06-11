import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/media/controllers/media_list_controller.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/album_create_page.dart';
import 'package:kairete/features/media/pages/media_compose_page.dart';
import 'package:kairete/features/media/widgets/album_cover_header.dart';
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
    final isAlbumView = filterAlbumId != null;
    final isFiltered = filterAlbumId != null || filterCategoryId != null;
    final showBar = showActionBar && (!isFiltered || isAlbumView);

    Widget buildCard(MediaItem item) {
      return MediaFeedCard(
        item: item,
        onOpen: () => controller.openDetail(item),
        onComment: () => controller.openDetail(item),
        onReact: (reactionId) =>
            controller.react(item, reactionId: reactionId),
        onAuthorTap: () => controller.openAuthorProfile(item),
        onAlbumTap: () => controller.openAlbumFilter(item),
        onCategoryTap: () => controller.openCategoryFilter(item),
        onThumbnailTap: () => controller.openViewer(item),
        onTagTap: TagFeedNavigation.openTag,
      );
    }

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showBar)
          Obx(
            () => MediaActionBar(
              onTapRefresh: controller.refreshAll,
              onTapAddMedia: () async {
                await Get.to(() => const MediaComposePage());
                await controller.refreshAll();
              },
              onTapCreateAlbum: () async {
                final created =
                    await Get.to<bool>(() => const AlbumCreatePage());
                if (created == true) await controller.refreshAll();
              },
              showJoin: isAlbumView,
              isJoined: controller.isWatched.value,
              joinLoading: controller.watchLoading.value,
              onTapJoin: controller.toggleWatch,
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

            final profile = controller.albumProfile.value;
            final showCover = isAlbumView && profile != null;
            final headerCount = showCover ? 1 : 0;

            if (controller.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: controller.refreshAll,
                child: ListView(
                  children: [
                    if (showCover) AlbumCoverHeader(profile: profile!),
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
                itemCount: controller.items.length + headerCount,
                itemBuilder: (_, i) {
                  if (showCover && i == 0) {
                    return AlbumCoverHeader(profile: profile!);
                  }
                  final item = controller.items[i - headerCount];
                  return buildCard(item);
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
