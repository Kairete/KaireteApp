class OmnifeedTab {
  const OmnifeedTab({
    required this.tabId,
    required this.title,
    required this.tabKey,
    required this.icon,
    required this.sortMode,
    this.displayOrder = 0,
    this.criteria = const {},
  });

  final int tabId;
  final String title;
  final String tabKey;
  final String icon;
  final String sortMode;
  final int displayOrder;
  final Map<String, dynamic> criteria;

  String get sortLabel {
    switch (sortMode) {
      case 'last_comment':
      case 'last_activity':
        return 'Ultimo commento';
      case 'last_like':
        return 'Ultimo like';
      case 'author_reaction_score':
        return 'Reaction score autore';
      default:
        return 'Recentezza';
    }
  }

  String get tooltip {
    final t = title.trim();
    if (t.isEmpty) return tabKey;
    return '$t · $sortLabel';
  }

  bool _crit(String key) => criteria[key] == true;

  /// Tab basato solo su autori (own/following/…), senza sorgenti “aperte”.
  bool get isAuthorOnlyCriteria {
    final hasAuthor = _crit('own') ||
        _crit('following') ||
        _crit('followers') ||
        _crit('same_group_users');
    final hasOpen = _crit('watch') ||
        _crit('group_posts') ||
        _crit('group_keywords') ||
        _crit('feed_comments') ||
        _crit('feed_reactions');
    return hasAuthor && !hasOpen;
  }

  bool get wantsOwn => _crit('own');
  bool get wantsFollowing => _crit('following');
  bool get wantsFollowers => _crit('followers');

  factory OmnifeedTab.fromJson(Map<String, dynamic> json) {
    final rawCriteria = json['criteria'];
    return OmnifeedTab(
      tabId: (json['tab_id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      tabKey: (json['tab_key'] as String?)?.trim() ?? '',
      icon: (json['icon'] as String?)?.trim() ?? 'fa-rss',
      sortMode: (json['sort_mode'] as String?)?.trim() ?? 'post_date',
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      criteria: rawCriteria is Map
          ? Map<String, dynamic>.from(rawCriteria)
          : const {},
    );
  }
}
