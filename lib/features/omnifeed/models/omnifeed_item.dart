class OmnifeedFeed {
  OmnifeedFeed({required this.items});

  final List<OmnifeedItem> items;

  factory OmnifeedFeed.fromJson(Map<String, dynamic> json) {
    final raw = json['newsfeedItems'] as List<dynamic>? ?? [];
    return OmnifeedFeed(
      items: raw
          .map((e) => OmnifeedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OmnifeedItem {
  OmnifeedItem({
    required this.itemId,
    this.contentType,
    this.contentTitle,
    this.messagePlainText,
    this.messageParsed,
    this.itemDate,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.author,
    this.categoryLabel,
    this.viewUrl,
  });

  final int itemId;
  final String? contentType;
  final String? contentTitle;
  final String? messagePlainText;
  final String? messageParsed;
  final int? itemDate;
  final int commentCount;
  final int reactionScore;
  final OmnifeedAuthor? author;
  final String? categoryLabel;
  final String? viewUrl;

  /// Post sul profilo/newsfeed: solo testo nel body, senza titolo modulo.
  bool get isPlainFeedPost => contentType == 'profile_post';

  /// Thread, blog, gruppo, articolo, ecc.: titolo nel body sotto l'header.
  bool get showsModuleTitle =>
      !isPlainFeedPost && (contentTitle?.trim().isNotEmpty ?? false);

  String get moduleTitle => contentTitle?.trim() ?? '';

  /// Forum, blog, gruppo, ecc. accanto al nickname nell'header (stile web).
  String? get headerModuleLabel {
    if (isPlainFeedPost) return null;
    final category = categoryLabel?.trim();
    if (category != null && category.isNotEmpty) return category;
    final label = typeLabel.trim();
    return label.isNotEmpty ? label : null;
  }

  String get displayTitle =>
      contentTitle?.trim().isNotEmpty == true
          ? contentTitle!
          : (author?.username ?? '');

  String get displayBody {
    final plain = messagePlainText?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    final parsed = messageParsed?.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
    if (parsed != null && parsed.isNotEmpty) return parsed;
    return contentTitle ?? '';
  }

  String get typeLabel {
    switch (contentType) {
      case 'profile_post':
        return 'Post';
      case 'thread':
        return 'Discussione';
      case 'ubs_blog_entry':
        return 'Blog';
      case 'ams_article':
        return 'Articolo';
      case 'tl_group_post':
        return 'Gruppo';
      case 'xfmg_media':
        return 'Media';
      default:
        return contentType ?? 'Contenuto';
    }
  }

  factory OmnifeedItem.fromJson(Map<String, dynamic> json) {
    final content = json['Content'] as Map<String, dynamic>?;
    final profile = json['ProfilePost'] as Map<String, dynamic>?;
    final group = json['GroupPost'] as Map<String, dynamic>?;

    String? category;
    if (content?['Category'] is Map) {
      category = (content!['Category'] as Map)['title']?.toString();
    } else if (profile?['Category'] is Map) {
      category = (profile!['Category'] as Map)['title']?.toString();
    } else if (group?['Group'] is Map) {
      category = (group!['Group'] as Map)['name']?.toString();
    }

    return OmnifeedItem(
      itemId: json['item_id'] as int? ?? 0,
      contentType: json['content_type']?.toString(),
      contentTitle: json['ContentTitle']?.toString(),
      messagePlainText: json['message_plain_text']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      itemDate: json['item_date'] as int?,
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      author: json['User'] is Map
          ? OmnifeedAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : null,
      categoryLabel: category,
      viewUrl: json['view_url']?.toString(),
    );
  }
}

class OmnifeedAuthor {
  OmnifeedAuthor({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;

  String get label => displayName?.trim().isNotEmpty == true
      ? displayName!
      : username;

  factory OmnifeedAuthor.fromJson(Map<String, dynamic> json) {
    String? avatar;
    final urls = json['avatar_urls'];
    if (urls is Map) {
      avatar = urls['m']?.toString() ?? urls['s']?.toString();
    }
    String? fullName;
    final fields = json['custom_fields'];
    if (fields is Map) {
      final first = fields['firstName']?.toString() ?? '';
      final last = fields['lastName']?.toString() ?? '';
      fullName = '$first $last'.trim();
      if (fullName.isEmpty) fullName = null;
    }
    return OmnifeedAuthor(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
      displayName: fullName,
    );
  }
}
