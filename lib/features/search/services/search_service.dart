import 'package:kairete/config/api_paths.dart';
import 'package:kairete/core/api/app_api.dart';
import 'package:kairete/core/api/xenforo_api.dart';
import 'package:kairete/core/utils/json_parse.dart';
import 'package:kairete/features/search/models/search_models.dart';

class SearchException implements Exception {
  SearchException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SearchService {
  XenforoApi get _api => AppApi.instance.xenforo;

  Future<SearchSuggestResponse> suggest(String query) async {
    await AppApi.instance.applySession();
    final q = query.trim();
    if (q.length < 2) {
      return SearchSuggestResponse(suggestions: const [], users: const [], q: q);
    }
    final json = await _api.get(
      ApiPaths.searchSuggest,
      query: {'q': q, 'limit': 8},
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw SearchException(err);
    return SearchSuggestResponse.fromJson(json);
  }

  Future<SearchPageResult> search(String keywords, {int page = 1}) async {
    await AppApi.instance.applySession();
    final q = keywords.trim();
    if (q.isEmpty) {
      throw SearchException('Inserisci un termine di ricerca.');
    }

    final created = await _api.post(
      '${ApiPaths.search}/',
      body: {
        'keywords': q,
        'search_type': '',
        'order': 'relevance',
      },
    );
    final createErr = XenforoApi.firstErrorMessage(created);
    if (createErr != null) throw SearchException(createErr);

    final searchMap = created['search'];
    if (searchMap is! Map) {
      throw SearchException('Nessun risultato trovato.');
    }
    final searchId = JsonParse.intValue(searchMap['search_id']);
    final resultCount = JsonParse.intValue(searchMap['result_count']);
    if (searchId <= 0) {
      throw SearchException('Nessun risultato trovato.');
    }
    if (resultCount <= 0) {
      return SearchPageResult(
        searchId: searchId,
        query: q,
        results: const [],
        resultCount: 0,
      );
    }

    return fetchSearchPage(searchId, query: q, page: page);
  }

  Future<SearchPageResult> fetchSearchPage(
    int searchId, {
    required String query,
    int page = 1,
  }) async {
    await AppApi.instance.applySession();
    final json = await _api.get(
      '${ApiPaths.search}/$searchId/',
      query: {'page': page},
    );
    final err = XenforoApi.firstErrorMessage(json);
    if (err != null) throw SearchException(err);

    final results = <SearchResultItem>[];
    final raw = json['results'];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          results.add(SearchResultItem.fromApi(Map<String, dynamic>.from(row)));
        }
      }
    }

    final searchMap = json['search'] is Map
        ? Map<String, dynamic>.from(json['search'] as Map)
        : <String, dynamic>{};
    final pagination = json['pagination'] is Map
        ? Map<String, dynamic>.from(json['pagination'] as Map)
        : <String, dynamic>{};

    return SearchPageResult(
      searchId: searchId,
      query: query,
      results: results,
      resultCount: JsonParse.intValue(
        searchMap['result_count'],
        fallback: results.length,
      ),
      currentPage: JsonParse.intValue(pagination['current_page'], fallback: page),
      lastPage: JsonParse.intValue(pagination['last_page'], fallback: 1),
    );
  }
}
