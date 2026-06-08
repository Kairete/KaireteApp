import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/blog/pages/blog_compose_page.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/groups/pages/group_detail_page.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_compose_page.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_detail_page.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_content_filters.dart';

class OmnifeedController extends GetxController {
  final OmnifeedService _service = OmnifeedService();

  final items = <OmnifeedItem>[].obs;
  final commentsByItemId = <int, List<OmnifeedComment>>{}.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final feedModeIndex = 0.obs;
  final sortByLastComment = false.obs;

  String get _feedMode =>
      OmnifeedContentFilters.modes[feedModeIndex.value.clamp(0, 3)];

  String get _feedSort => sortByLastComment.value ? 'last_activity' : 'post_date';

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  void setFeedModeIndex(int index) {
    if (feedModeIndex.value == index) return;
    feedModeIndex.value = index;
    loadFeed();
  }

  void setSortByLastComment(bool value) {
    if (sortByLastComment.value == value) return;
    sortByLastComment.value = value;
    loadFeed();
  }

  Future<void> loadFeed() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final feed = await _service
          .fetchFeed(mode: _feedMode, sort: _feedSort)
          .timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException('feed'),
      );
      items.value = feed.items;
      await _loadInlineComments(feed.items);
    } on TimeoutException {
      errorMessage.value =
          'Il feed impiega troppo tempo. Controlla la rete e riprova.';
    } on OmnifeedException catch (e) {
      errorMessage.value = e.message;
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      errorMessage.value = 'Impossibile caricare il feed.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> react(OmnifeedItem item, {int reactionId = 1}) async {
    try {
      final action = await _service.reactToItem(item: item, reactionId: reactionId);
      _bumpScore(item.itemId, action);
      AppToast.success(
        action == 'delete' ? 'Reazione rimossa.' : 'Reazione inviata.',
      );
      await loadFeed();
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  void _bumpScore(int itemId, String action) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    final delta = action == 'delete' ? -1 : 1;
    final current = items[index];
    final next = current.reactionScore + delta;
    items[index] = current.copyWith(reactionScore: next < 0 ? 0 : next);
    items.refresh();
  }

  Future<void> _loadInlineComments(List<OmnifeedItem> feedItems) async {
    final targets = feedItems
        .where(
          (item) =>
              item.contentType == 'profile_post' && item.commentCount > 0,
        )
        .toList();
    if (targets.isEmpty) {
      commentsByItemId.clear();
      return;
    }

    final loaded = <int, List<OmnifeedComment>>{};
    await Future.wait(
      targets.map((item) async {
        try {
          final page = await _service.fetchComments(item.itemId);
          loaded[item.itemId] = page.comments;
        } catch (_) {
          loaded[item.itemId] = const [];
        }
      }),
    );
    commentsByItemId.value = loaded;
  }

  void openDetail(OmnifeedItem item) {
    final contentId = item.contentId;
    switch (item.contentType) {
      case 'tl_group_post':
      case 'ksg_group_post':
        final groupId = item.groupId ?? _groupIdFromViewUrl(item.viewUrl);
        if (groupId != null && groupId > 0) {
          Get.to(() => GroupDetailPage(groupId: groupId));
          return;
        }
        break;
      case 'thread':
        if (contentId != null && contentId > 0) {
          Get.to(
            () => ThreadDetailPage(
              threadId: contentId,
              forumTitle: item.categoryLabel ?? item.moduleTitle,
            ),
          );
          return;
        }
        break;
      case 'ubs_blog_entry':
        if (contentId != null && contentId > 0) {
          Get.to(() => BlogDetailPage(entryId: contentId));
          return;
        }
        break;
    }
    Get.to(() => OmnifeedDetailPage(item: item));
  }

  int? _groupIdFromViewUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(r'social-groups/[^./]+\.(\d+)').firstMatch(url);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Future<void> openCompose() async {
    final created = await Get.to<bool>(() => const OmnifeedComposePage());
    if (created == true) await loadFeed();
  }

  Future<bool> openBlogCompose() async {
    final created = await Get.to<bool>(() => const BlogComposePage());
    if (created == true) {
      await loadFeed();
      return true;
    }
    return false;
  }
}
