import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/app_toast.dart';
import 'package:kairete/features/blog/pages/blog_detail_page.dart';
import 'package:kairete/features/forum/pages/thread_detail_page.dart';
import 'package:kairete/features/media/pages/media_detail_page.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_navigation.dart';
import 'package:kairete/features/search/models/search_models.dart';
import 'package:kairete/features/search/services/search_service.dart';

class AppSearchController extends GetxController {
  final SearchService _service = SearchService();

  final query = ''.obs;
  final suggestions = <SearchSuggestion>[].obs;
  final users = <SearchUserHit>[].obs;
  final results = <SearchResultItem>[].obs;
  final isSuggesting = false.obs;
  final isSearching = false.obs;
  final hasSearched = false.obs;
  final resultCount = 0.obs;
  final errorMessage = ''.obs;

  int _searchId = 0;
  int _page = 1;
  int _lastPage = 1;
  Timer? _debounce;
  int _suggestSeq = 0;

  bool get hasMore => _page < _lastPage;
  bool get showSuggestions =>
      !hasSearched.value &&
      query.value.trim().length >= 2 &&
      (suggestions.isNotEmpty || users.isNotEmpty || isSuggesting.value);

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  void onQueryChanged(String value) {
    query.value = value;
    hasSearched.value = false;
    results.clear();
    errorMessage.value = '';
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      suggestions.clear();
      users.clear();
      isSuggesting.value = false;
      return;
    }
    isSuggesting.value = true;
    _debounce = Timer(const Duration(milliseconds: 280), () {
      _loadSuggestions(q);
    });
  }

  Future<void> _loadSuggestions(String q) async {
    final seq = ++_suggestSeq;
    try {
      final res = await _service.suggest(q);
      if (seq != _suggestSeq || query.value.trim() != q) return;
      suggestions.assignAll(res.suggestions);
      users.assignAll(res.users);
    } on SearchException catch (e) {
      if (seq != _suggestSeq) return;
      suggestions.clear();
      users.clear();
      errorMessage.value = e.message;
    } on DioException catch (e) {
      if (seq != _suggestSeq) return;
      suggestions.clear();
      users.clear();
      errorMessage.value = XenforoApi.connectionMessage(e);
    } catch (_) {
      if (seq != _suggestSeq) return;
      suggestions.clear();
      users.clear();
    } finally {
      if (seq == _suggestSeq) isSuggesting.value = false;
    }
  }

  Future<void> submit([String? raw]) async {
    final q = (raw ?? query.value).trim();
    if (q.isEmpty) return;
    query.value = q;
    _debounce?.cancel();
    suggestions.clear();
    users.clear();
    isSuggesting.value = false;
    isSearching.value = true;
    hasSearched.value = true;
    errorMessage.value = '';
    results.clear();
    try {
      final page = await _service.search(q, page: 1);
      _searchId = page.searchId;
      _page = page.currentPage;
      _lastPage = page.lastPage;
      resultCount.value = page.resultCount;
      results.assignAll(page.results);
      if (page.results.isEmpty) {
        errorMessage.value = 'Nessun risultato per “$q”.';
      }
    } on SearchException catch (e) {
      errorMessage.value = e.message;
      AppToast.error(AppToast.mapApiError(e.message));
    } on DioException catch (e) {
      errorMessage.value = XenforoApi.connectionMessage(e);
      AppToast.error(errorMessage.value);
    } catch (_) {
      errorMessage.value = 'Ricerca non riuscita.';
      AppToast.error(errorMessage.value);
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || isSearching.value || _searchId <= 0) return;
    isSearching.value = true;
    try {
      final page = await _service.fetchSearchPage(
        _searchId,
        query: query.value.trim(),
        page: _page + 1,
      );
      _page = page.currentPage;
      _lastPage = page.lastPage;
      results.addAll(page.results);
    } catch (_) {
      AppToast.error('Impossibile caricare altri risultati.');
    } finally {
      isSearching.value = false;
    }
  }

  void openSuggestion(SearchSuggestion item) {
    _openContent(item.contentType, item.contentId, title: item.title);
  }

  void openUser(SearchUserHit user) {
    OmnifeedNavigation.openUserProfile(user.userId, username: user.username);
  }

  void openResult(SearchResultItem item) {
    _openContent(
      item.type,
      item.id,
      title: item.title,
      nodeId: item.nodeId,
      userId: item.userId,
      threadId: item.threadId,
    );
  }

  void _openContent(
    String type,
    int id, {
    String title = '',
    int nodeId = 0,
    int userId = 0,
    int threadId = 0,
  }) {
    if (id <= 0 && threadId <= 0) return;
    switch (type) {
      case 'thread':
        Get.to(() => ThreadDetailPage(threadId: id));
        return;
      case 'post':
        final tid = threadId > 0 ? threadId : id;
        Get.to(() => ThreadDetailPage(threadId: tid));
        return;
      case 'xfmg_media':
      case 'media':
        Get.to(() => MediaDetailPage(mediaId: id));
        return;
      case 'ubs_blog_entry':
      case 'blog_entry':
        Get.to(() => BlogDetailPage(entryId: id));
        return;
      case 'user':
      case 'member':
        OmnifeedNavigation.openUserProfile(id);
        return;
      case 'profile_post':
        if (userId > 0) {
          OmnifeedNavigation.openUserProfile(userId);
        }
        return;
      default:
        AppToast.error('Tipo contenuto non supportato: $type');
    }
  }
}
