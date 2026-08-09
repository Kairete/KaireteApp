import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/config/app_config.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/services/content_owner_service.dart';
import 'package:kairete/core/tenant/tenant_bootstrap.dart';
import 'package:kairete/core/tenant/tenant_scope.dart';
import 'package:kairete/core/tenant/tenant_service.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/core/utils/content_edit_helper.dart';
import 'package:kairete/features/auth/controllers/auth_flow_controller.dart';
import 'package:kairete/features/blog/pages/blog_compose_page.dart';
import 'package:kairete/features/app_widgets/utils/app_widget_placements.dart';
import 'package:kairete/features/app_widgets/utils/app_widgets_list_mixin.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_item.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_tab.dart';
import 'package:kairete/features/omnifeed/pages/omnifeed_compose_page.dart';
import 'package:kairete/features/omnifeed/services/omnifeed_service.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/omnifeed/widgets/omnifeed_content_filters.dart';
import 'package:kairete/features/profile/services/profile_service.dart';

class OmnifeedController extends GetxController with AppWidgetsListMixin {
  final OmnifeedService _service = OmnifeedService();
  final ContentOwnerService _ownerService = ContentOwnerService();
  final ProfileService _profileService = ProfileService();

  /// Garantisce che il controller esista (GetX a volte lo rimuove navigando).
  static OmnifeedController ensure() {
    if (!Get.isRegistered<OmnifeedController>()) {
      Get.put(OmnifeedController(), permanent: true);
    }
    return Get.find<OmnifeedController>();
  }

  final items = <OmnifeedItem>[].obs;
  final feedTabs = <OmnifeedTab>[].obs;
  /// True dopo la prima risposta (anche vuota) da api/newsfeed/tabs.
  final feedTabsReady = false.obs;
  /// True se l'endpoint tabs ha fallito: usa i 4 mode legacy.
  final feedTabsApiFailed = false.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = ''.obs;
  final feedModeIndex = 0.obs;
  final tenantFeedFilterIndex = 0.obs;
  /// User id già seguiti in questa sessione (nasconde "Segui" nell'header).
  final followedAuthorIds = <int>{}.obs;
  final sortMode = 'post_date'.obs;
  final showScopeSyncDebug = false.obs;
  final hasMorePages = false.obs;
  /// Messaggio vuoto contestuale (es. nessun follower).
  final emptyFeedHint = ''.obs;

  int _currentPage = 1;
  String? _preferredTabKey;
  /// Ignora risposte feed obsolete quando l’utente cambia tab rapidamente.
  int _feedLoadSeq = 0;

  bool get sortByLastComment =>
      sortMode.value == 'last_comment' || sortMode.value == 'last_activity';

  bool get _usesAcpTabs =>
      !AppConfig.isTenantApp && feedTabs.isNotEmpty;

  String get _feedMode {
    if (AppConfig.isTenantApp) return 'tenant_group';
    if (feedTabs.isNotEmpty) {
      final i = feedModeIndex.value.clamp(0, feedTabs.length - 1);
      return feedTabs[i].tabKey;
    }
    if (feedTabsApiFailed.value) {
      return OmnifeedContentFilters.legacyModes[
          feedModeIndex.value.clamp(
            0,
            OmnifeedContentFilters.legacyModes.length - 1,
          )];
    }
    // Nessun tab ACP: non usare 'all' (riempirebbe il feed senza criteri).
    return '';
  }

  String get _tenantFeedFilter =>
      tenantFeedFilterIndex.value == 1 ? 'following' : 'all';

  /// Con tab ACP lo sort è quello del tab (il server lo impone).
  String get _feedSort {
    if (_usesAcpTabs) {
      final i = feedModeIndex.value.clamp(0, feedTabs.length - 1);
      return feedTabs[i].sortMode;
    }
    return sortMode.value;
  }

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  void setFeedModeIndex(int index) {
    if (feedModeIndex.value == index) return;
    feedModeIndex.value = index;
    if (feedTabs.isNotEmpty) {
      final i = index.clamp(0, feedTabs.length - 1);
      _preferredTabKey = feedTabs[i].tabKey;
      sortMode.value = feedTabs[i].sortMode;
    }
    // Svuota subito: altrimenti resta il feed del tab precedente (sembra
    // che i filtri non cambino) e una risposta lenta può sovrascrivere.
    items.clear();
    emptyFeedHint.value = '';
    errorMessage.value = '';
    hasMorePages.value = false;
    loadFeed();
  }

  void setTenantFeedFilterIndex(int index) {
    final next = index.clamp(0, 1);
    if (tenantFeedFilterIndex.value == next) return;
    tenantFeedFilterIndex.value = next;
    items.clear();
    emptyFeedHint.value = '';
    errorMessage.value = '';
    hasMorePages.value = false;
    loadFeed();
  }

  void setSortMode(String value) {
    if (_usesAcpTabs) return;
    if (sortMode.value == value) return;
    sortMode.value = value;
    items.clear();
    emptyFeedHint.value = '';
    errorMessage.value = '';
    hasMorePages.value = false;
    loadFeed();
  }

  void setSortByLastComment(bool value) {
    setSortMode(value ? 'last_comment' : 'post_date');
  }

  Future<void> _refreshTabsFromServer() async {
    if (AppConfig.isTenantApp) {
      feedTabs.clear();
      feedTabsReady.value = true;
      feedTabsApiFailed.value = false;
      return;
    }
    try {
      final tabs = await _service.fetchTabs();
      feedTabsApiFailed.value = false;
      _applyTabs(tabs);
    } catch (_) {
      // Endpoint assente/errore: non azzerare tab già noti.
      if (feedTabs.isEmpty) {
        feedTabsApiFailed.value = true;
      }
    } finally {
      feedTabsReady.value = true;
    }
  }

  void _applyTabs(List<OmnifeedTab> tabs) {
    feedTabs.assignAll(tabs);
    if (tabs.isEmpty) {
      feedModeIndex.value = 0;
      return;
    }
    var idx = 0;
    final preferred = _preferredTabKey;
    if (preferred != null && preferred.isNotEmpty) {
      final found = tabs.indexWhere((t) => t.tabKey == preferred);
      if (found >= 0) idx = found;
    } else {
      idx = feedModeIndex.value.clamp(0, tabs.length - 1);
    }
    feedModeIndex.value = idx;
    _preferredTabKey = tabs[idx].tabKey;
    sortMode.value = tabs[idx].sortMode;
  }

  String _emptyHintForFeed(OmnifeedFeed feed) {
    final mode = (feed.mode ?? _feedMode).trim();
    final modePrefix = mode.isEmpty ? '' : 'Tab “$mode”.\n';
    final ver = (feed.omnifeedVersion ?? _service.lastOmnifeedVersion ?? '')
        .trim();
    final verHint = ver.isEmpty
        ? 'Server OmniFeed non aggiornato (manca 1.8.119).\n'
        : 'OmniFeed $ver.\n';
    final d = feed.criteriaDebug;
    if (d.isEmpty) {
      return '$modePrefix${verHint}Nessun contenuto nel feed.';
    }
    final followers = d['followers'] == true;
    final following = d['following'] == true;
    final watch = d['watch'] == true;
    final authorIds = (d['author_ids'] is num) ? (d['author_ids'] as num).toInt() : -1;
    final followerIds =
        (d['follower_ids'] is num) ? (d['follower_ids'] as num).toInt() : 0;
    final fanIds =
        (d['fan_follower_ids'] is num) ? (d['fan_follower_ids'] as num).toInt() : 0;
    if (watch &&
        !following &&
        !followers &&
        d['own'] != true &&
        d['group_posts'] != true) {
      final forums = (d['watch_forum_ids'] is num) ? (d['watch_forum_ids'] as num).toInt() : -1;
      final threads = (d['watch_thread_ids'] is num) ? (d['watch_thread_ids'] as num).toInt() : -1;
      final blogs = (d['watch_blog_ids'] is num) ? (d['watch_blog_ids'] as num).toInt() : -1;
      final albums = (d['watch_album_ids'] is num) ? (d['watch_album_ids'] as num).toInt() : -1;
      return '$modePrefix${verHint}Watch: forum=$forums, thread=$threads, blog=$blogs, album=$albums.\n'
          'Se tutti 0, il server non trova watch su questo account.';
    }
    if (followers && !following && authorIds == 0) {
      return '$modePrefix${verHint}Nessun utente ti segue (XF: $followerIds, fan: $fanIds).\n'
          'Chi ti segue con “Segui” o Become fan comparirà qui.';
    }
    if (followers && authorIds > 0) {
      return '$modePrefix${verHint}Hai $authorIds autori nel criterio “mi seguono”, '
          'ma nessun contenuto recente.';
    }
    if (following && authorIds == 0) {
      return '$modePrefix${verHint}Non segui ancora nessuno (o il server non trova relazioni).';
    }
    return '$modePrefix${verHint}Nessun contenuto nel feed.';
  }

  void _syncFromFeedResponse(
    OmnifeedFeed feed, {
    required String requestedMode,
  }) {
    final serverSort = feed.sort;
    if (serverSort != null && serverSort.isNotEmpty) {
      // last_activity (API) ↔ last_comment (ACP/UI)
      sortMode.value = serverSort == 'last_activity' ? 'last_comment' : serverSort;
    }
    final serverMode = feed.mode;
    // Non far “saltare” il tab selezionato se la risposta è di un altro mode.
    if (requestedMode.isNotEmpty &&
        serverMode != null &&
        serverMode.isNotEmpty &&
        serverMode != requestedMode) {
      return;
    }
    if (serverMode != null &&
        serverMode.isNotEmpty &&
        feedTabs.isNotEmpty) {
      final found = feedTabs.indexWhere((t) => t.tabKey == serverMode);
      if (found >= 0) {
        feedModeIndex.value = found;
        _preferredTabKey = serverMode;
      }
    }
  }

  Future<void> loadFeed({bool syncScope = false}) async {
    final seq = ++_feedLoadSeq;
    isLoading.value = true;
    errorMessage.value = '';
    _currentPage = 1;
    try {
      if (AppConfig.isTenantApp && syncScope) {
        await TenantService().syncScopeFromServer();
      }
      await _refreshTabsFromServer();
      if (seq != _feedLoadSeq) return;
      // Hub senza tab ACP: niente striscia e niente feed "all" di default.
      if (!AppConfig.isTenantApp &&
          feedTabs.isEmpty &&
          !feedTabsApiFailed.value) {
        items.clear();
        hasMorePages.value = false;
        _currentPage = 1;
        emptyFeedHint.value =
            'Nessun tab newsfeed configurato.\nAggiungili da ACP → OmniFeed - Tab newsfeed.';
      } else {
        final requestedMode = _feedMode;
        OmnifeedTab? acpTab;
        if (feedTabs.isNotEmpty) {
          final i = feedModeIndex.value.clamp(0, feedTabs.length - 1);
          acpTab = feedTabs[i];
        }
        final feed = await _service
            .fetchFeed(
              mode: requestedMode,
              sort: _feedSort,
              feedFilter: _tenantFeedFilter,
              page: 1,
              limit: 40,
              acpTab: acpTab,
            )
            .timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw TimeoutException('feed'),
        );
        if (seq != _feedLoadSeq) return;
        _syncFromFeedResponse(feed, requestedMode: requestedMode);
        items.value = feed.items;
        await _applyNewsfeedHighlightFlags();
        if (seq != _feedLoadSeq) return;
        _currentPage = feed.currentPage;
        hasMorePages.value = feed.hasMorePages;
        emptyFeedHint.value = feed.items.isEmpty
            ? _emptyHintForFeed(feed)
            : '';
      }
      if (seq != _feedLoadSeq) return;
      if (AppConfig.isTenantApp &&
          items.isEmpty &&
          !TenantScope.hasMappedModules) {
        errorMessage.value = TenantService.mappingUnavailableMessage();
      }
    } on TimeoutException {
      if (seq != _feedLoadSeq) return;
      errorMessage.value =
          'Il feed impiega troppo tempo. Controlla la rete e riprova.';
    } on OmnifeedException catch (e) {
      if (seq != _feedLoadSeq) return;
      errorMessage.value = AppToast.mapApiError(e.message);
    } on DioException catch (e) {
      if (seq != _feedLoadSeq) return;
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      if (seq != _feedLoadSeq) return;
      errorMessage.value = 'Impossibile caricare il feed.';
    } finally {
      if (seq == _feedLoadSeq) {
        if (AppConfig.isTenantApp) {
          showScopeSyncDebug.value = !TenantRuntime.lastScopeSyncOk;
        }
        isLoading.value = false;
      }
    }
    // Fuori dal try del feed: i widget non devono mai bloccare/rompere il newsfeed.
    if (seq != _feedLoadSeq) return;
    if (errorMessage.value.isEmpty) {
      try {
        await loadAppWidgets(
          AppWidgetPlacements.omnifeed,
          forceRefresh: true,
        );
      } catch (_) {}
    }
  }

  Future<void> loadMoreFeed() async {
    if (isLoading.value || isLoadingMore.value || !hasMorePages.value) return;
    if (!AppConfig.isTenantApp &&
        feedTabs.isEmpty &&
        !feedTabsApiFailed.value) {
      hasMorePages.value = false;
      return;
    }
    final seq = _feedLoadSeq;
    final requestedMode = _feedMode;
    isLoadingMore.value = true;
    try {
      final nextPage = _currentPage + 1;
      final feed = await _service
          .fetchFeed(
            mode: requestedMode,
            sort: _feedSort,
            feedFilter: _tenantFeedFilter,
            page: nextPage,
            limit: 40,
          )
          .timeout(
        const Duration(seconds: 25),
        onTimeout: () => throw TimeoutException('feed'),
      );
      if (seq != _feedLoadSeq || requestedMode != _feedMode) return;
      if (feed.items.isEmpty) {
        hasMorePages.value = false;
        return;
      }
      final seen = items.map((e) => e.itemId).toSet();
      final appended = feed.items.where((e) => !seen.contains(e.itemId));
      items.addAll(appended);
      await _applyNewsfeedHighlightFlags();
      if (seq != _feedLoadSeq || requestedMode != _feedMode) return;
      _currentPage = feed.currentPage;
      hasMorePages.value = feed.hasMorePages;
    } catch (_) {
      // Silenzioso: resta la lista già caricata.
    } finally {
      if (seq == _feedLoadSeq) {
        isLoadingMore.value = false;
      }
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

  Future<void> toggleBookmark(OmnifeedItem item) async {
    try {
      final bookmarked = await _service.toggleBookmark(item);
      _setBookmarked(item.itemId, bookmarked);
      AppToast.success(bookmarked ? 'Salvato.' : 'Rimosso dai salvati.');
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  Future<void> toggleHighlight(OmnifeedItem item) async {
    try {
      final scope = (item.highlightScope ?? '').trim().isNotEmpty
          ? item.highlightScope
          : 'admin:newsfeed';
      final highlighted = await _service.toggleHighlight(
        item.copyWith(highlightScope: scope, canHighlight: true),
      );
      _setHighlighted(item.itemId, highlighted);
      AppToast.success(
        highlighted ? 'Fissato in alto.' : 'Tolto dall\'alto.',
      );
    } on OmnifeedException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  /// Allinea flag pin da GET highlights e porta i fissati in cima (stesso DB del web).
  Future<void> _applyNewsfeedHighlightFlags() async {
    const scope = 'admin:newsfeed';
    try {
      final page = await _service.fetchHighlights(scope);
      final pinnedIds = page.itemIds;
      final pinned = pinnedIds.toSet();
      var next = items.map((item) {
        final isPinned = pinned.contains(item.itemId) || item.isHighlighted;
        return item.copyWith(
          canHighlight: page.canManage || item.canHighlight || isPinned,
          highlightScope: item.highlightScope ?? scope,
          isHighlighted: isPinned,
        );
      }).toList();
      if (pinnedIds.isNotEmpty) {
        next = OmnifeedService.pinByItemIds(next, pinnedIds);
      } else {
        next = OmnifeedService.sortHubItems(next, _feedSort);
      }
      items.assignAll(next);
    } catch (_) {
      items.assignAll(
        OmnifeedService.sortHubItems(items.toList(), _feedSort),
      );
    }
  }

  void _setBookmarked(int itemId, bool bookmarked) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    items[index] = items[index].copyWith(isBookmarked: bookmarked);
    items.refresh();
  }

  void _setHighlighted(int itemId, bool highlighted) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index < 0) return;
    items[index] = items[index].copyWith(isHighlighted: highlighted);
    items.value = OmnifeedService.sortHubItems(items.toList(), _feedSort);
  }

  /// Aggiorna [shareCount] e, se presente, inserisce il post creato in cima.
  void applyShareResult(int itemId, FeedShareApiResult result) {
    final index = items.indexWhere((entry) => entry.itemId == itemId);
    if (index >= 0) {
      items[index] = items[index].copyWith(shareCount: result.shareCount);
    }
    final created = result.createdItem;
    if (created != null) {
      prependItem(created);
    } else {
      items.refresh();
    }
  }

  void openDetail(OmnifeedItem item) => OmnifeedNavigation.openDetail(item);

  void openAuthor(OmnifeedItem item) => OmnifeedNavigation.openAuthor(item);

  void openBlog(OmnifeedItem item) => OmnifeedNavigation.openBlog(item);

  void openForum(OmnifeedItem item) => OmnifeedNavigation.openForum(item);

  Future<void> openCompose() async {
    final created = await Get.to<OmnifeedItem?>(() => const OmnifeedComposePage());
    if (created != null) {
      prependItem(created);
    }
    await loadFeed();
  }

  void prependItem(OmnifeedItem item) {
    if (item.itemId <= 0) return;
    final index = items.indexWhere((entry) => entry.itemId == item.itemId);
    if (index >= 0) {
      items[index] = item;
    } else {
      items.insert(0, item);
    }
    items.refresh();
  }

  Future<bool> openBlogCompose() async {
    final created = await Get.to<bool>(() => const BlogComposePage());
    if (created == true) {
      await loadFeed();
      return true;
    }
    return false;
  }

  bool isOwnedByCurrentUser(OmnifeedItem item) {
    if (!Get.isRegistered<AuthFlowController>()) return false;
    final userId = Get.find<AuthFlowController>().currentUser.value?.userId;
    if (userId == null || userId <= 0) return false;
    return item.author?.userId == userId;
  }

  bool canShowFollow(OmnifeedItem item) {
    if (isOwnedByCurrentUser(item)) return false;
    final authorId = item.author?.userId ?? 0;
    if (authorId <= 0) return false;
    if (followedAuthorIds.contains(authorId)) return false;
    final module = item.sharedItem != null ? null : item.headerModuleLabel;
    if (module != null && module.trim().isNotEmpty) return false;
    if (item.sharedItem != null) return false;
    return true;
  }

  Future<void> followAuthor(OmnifeedItem item) async {
    final authorId = item.author?.userId ?? 0;
    if (authorId <= 0 || isOwnedByCurrentUser(item)) return;
    try {
      await _profileService.followUser(authorId, stop: false);
      followedAuthorIds.add(authorId);
      followedAuthorIds.refresh();
      AppToast.success('Ora segui ${item.author?.username ?? 'questo utente'}.');
    } on ProfileException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    } catch (e) {
      AppToast.error(AppToast.mapApiError(e.toString()));
    }
  }

  Future<void> editItem(OmnifeedItem item) async {
    if (item.contentType == 'ubs_blog_entry') {
      final updated = await Get.to<bool>(
        () => BlogComposePage(editEntryId: item.contentId),
      );
      if (updated == true) await loadFeed();
      return;
    }
    final context = Get.context;
    if (context == null) return;
    final result = await showContentEditDialog(context, item: item);
    if (result == null) return;
    try {
      await _ownerService.updateItem(
        item: item,
        title: result.title,
        message: result.message,
      );
      AppToast.success('Contenuto aggiornato.');
      await loadFeed();
    } on ContentOwnerException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }

  Future<void> deleteItem(OmnifeedItem item) async {
    final context = Get.context;
    if (context == null) return;
    final confirmed = await confirmDeleteContent(context);
    if (!confirmed) return;
    try {
      await _ownerService.deleteItem(item);
      AppToast.success('Contenuto eliminato.');
      await loadFeed();
    } on ContentOwnerException catch (e) {
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      AppToast.error(XenforoApi.connectionMessage(e));
    }
  }
}
