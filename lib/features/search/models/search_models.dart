class SearchSuggestion {
  SearchSuggestion({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.title,
    this.typeLabel = '',
    this.desc = '',
    this.url = '',
  });

  final String id;
  final String contentType;
  final int contentId;
  final String title;
  final String typeLabel;
  final String desc;
  final String url;

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json['id']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
      contentId: (json['content_id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      typeLabel: json['type_label']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class SearchUserHit {
  SearchUserHit({
    required this.userId,
    required this.username,
    this.avatarUrl,
  });

  final int userId;
  final String username;
  final String? avatarUrl;

  factory SearchUserHit.fromJson(Map<String, dynamic> json) {
    return SearchUserHit(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class SearchSuggestResponse {
  SearchSuggestResponse({
    required this.suggestions,
    required this.users,
    this.q = '',
  });

  final List<SearchSuggestion> suggestions;
  final List<SearchUserHit> users;
  final String q;

  factory SearchSuggestResponse.fromJson(Map<String, dynamic> json) {
    final suggestions = <SearchSuggestion>[];
    final rawSug = json['suggestions'];
    if (rawSug is List) {
      for (final row in rawSug) {
        if (row is Map) {
          suggestions.add(
            SearchSuggestion.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }
    final users = <SearchUserHit>[];
    final rawUsers = json['users'];
    if (rawUsers is List) {
      for (final row in rawUsers) {
        if (row is Map) {
          users.add(SearchUserHit.fromJson(Map<String, dynamic>.from(row)));
        }
      }
    }
    return SearchSuggestResponse(
      suggestions: suggestions,
      users: users,
      q: json['q']?.toString() ?? '',
    );
  }
}

class SearchResultItem {
  SearchResultItem({
    required this.type,
    required this.id,
    required this.title,
    this.snippet = '',
    this.username = '',
    this.userId = 0,
    this.viewUrl = '',
    this.nodeId = 0,
    this.threadId = 0,
  });

  final String type;
  final int id;
  final String title;
  final String snippet;
  final String username;
  final int userId;
  final String viewUrl;
  final int nodeId;
  final int threadId;

  factory SearchResultItem.fromApi(Map<String, dynamic> json) {
    final type = json['type']?.toString() ?? '';
    final id = (json['id'] as num?)?.toInt() ?? 0;
    final result = json['result'];
    final map = result is Map
        ? Map<String, dynamic>.from(result)
        : <String, dynamic>{};

    var title = (map['title']?.toString() ?? '').trim();
    if (title.isEmpty) {
      title = (map['username']?.toString() ?? '').trim();
    }
    if (title.isEmpty) {
      final msg = map['message']?.toString() ??
          map['message_plain_text']?.toString() ??
          '';
      title = msg.trim().isEmpty
          ? '#$id'
          : (msg.length > 80 ? '${msg.substring(0, 80)}…' : msg);
    }

    final snippet = map['message']?.toString() ??
        map['message_plain_text']?.toString() ??
        '';

    return SearchResultItem(
      type: type,
      id: id,
      title: title,
      snippet: snippet.length > 160 ? '${snippet.substring(0, 160)}…' : snippet,
      username: map['username']?.toString() ?? '',
      userId: (map['user_id'] as num?)?.toInt() ?? 0,
      viewUrl: map['view_url']?.toString() ?? '',
      nodeId: (map['node_id'] as num?)?.toInt() ?? 0,
      threadId: (map['thread_id'] as num?)?.toInt() ?? 0,
    );
  }
}

class SearchPageResult {
  SearchPageResult({
    required this.searchId,
    required this.query,
    required this.results,
    this.resultCount = 0,
    this.currentPage = 1,
    this.lastPage = 1,
  });

  final int searchId;
  final String query;
  final List<SearchResultItem> results;
  final int resultCount;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}
