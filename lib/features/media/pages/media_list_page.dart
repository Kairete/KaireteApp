import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/core/theme/app_theme.dart';
import 'package:kairete/features/app_widgets/models/app_widget_models.dart';
import 'package:kairete/features/app_widgets/widgets/app_widget_strip.dart';
import 'package:kairete/features/feed/widgets/feed_share_sheet.dart';
import 'package:kairete/features/suggestions/widgets/suggestions_feed_rail.dart';
import 'package:kairete/features/media/controllers/media_list_controller.dart';
import 'package:kairete/features/media/models/media_album_profile.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/media/pages/album_create_page.dart';
import 'package:kairete/features/media/pages/media_compose_page.dart';
import 'package:kairete/features/media/widgets/album_cover_header.dart';
import 'package:kairete/features/media/widgets/media_action_bar.dart';
import 'package:kairete/features/media/widgets/media_feed_card.dart';
import 'package:kairete/features/omnifeed/controllers/omnifeed_controller.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/tagfeed/utils/tagfeed_navigation.dart';

class MediaListPage extends StatelessWidget {
  MediaListPage({
    super.key,
    this.filterAlbumId,
    this.filterCategoryId,
    this.pageTitle,
    this.showActionBar = true,
    this.tenantMapped = false,
  });

  final int? filterAlbumId;
  final int? filterCategoryId;
  final String? pageTitle;
  final bool showActionBar;
  final bool tenantMapped;

  @override
  Widget build(BuildContext context) {
    final tag = tenantMapped
        ? 'media_tenant_mapped'
        : 'media_${filterAlbumId ?? 0}_${filterCategoryId ?? 0}';
    if (!Get.isRegistered<MediaListController>(tag: tag)) {
      Get.put(
        MediaListController(
          filterAlbumId: filterAlbumId,
          filterCategoryId: filterCategoryId,
          tenantMapped: tenantMapped,
        ),
        tag: tag,
      );
    }
    final controller = Get.find<MediaListController>(tag: tag);
    final isAlbumView = filterAlbumId != null;
    final isFiltered = filterAlbumId != null || filterCategoryId != null;
    final showBar = showActionBar && (tenantMapped || !isFiltered || isAlbumView);

    Future<void> openCreateAlbum() async {
      final created = await Get.to<bool>(() => const AlbumCreatePage());
      if (created == true) await controller.refreshAll();
    }

    Widget albumCoverHeader(MediaAlbumProfile profile) {
      return AlbumCoverHeader(
        profile: profile,
        onTapCreateAlbum: openCreateAlbum,
      );
    }

    Widget buildCard(MediaItem item) {
      return MediaFeedCard(
        item: item,
        showAlbumInHeader: !isAlbumView,
        onOpen: () => controller.openDetail(item),
        onComment: () => controller.openDetail(item),
        onReact: (reactionId) =>
            controller.react(item, reactionId: reactionId),
        onShareInternal: () async {
          final result = await showFeedShareInternal(
            context: context,
            itemId: OmnifeedItemId.encode(
              OmnifeedItemId.typeMedia,
              item.mediaId,
            ),
            previewText: item.description ?? item.title,
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
              OmnifeedItemId.typeMedia,
              item.mediaId,
            ),
            viewUrl: item.viewUrl,
          );
        },
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
                await Get.to(() => MediaComposePage(tenantMapped: tenantMapped));
                await controller.refreshAll();
              },
              onTapCreateAlbum: openCreateAlbum,
              showCreateAlbum: true,
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
                    if (showCover) albumCoverHeader(profile),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.35,
                      child: Center(
                        child: Text(
                          tenantMapped
                              ? 'Nessun media negli album mappati.'
                              : 'Nessun media.',
                        ),
                      ),
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
                  if (showCover && i == 0) {
                    return albumCoverHeader(profile);
                  }
                  final slot = slots[i - headerCount];
                  if (slot is SuggestionsRailMarker) {
                    return SuggestionsFeedRail(marker: slot);
                  }
                  if (slot is AppWidgetStripMarker) {
                    return AppWidgetStrip(widgets: slot.widgets);
                  }
                  return buildCard(slot as MediaItem);
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
