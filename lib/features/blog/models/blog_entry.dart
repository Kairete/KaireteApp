class BlogAuthor {
  BlogAuthor({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;

  String get label =>
      displayName?.trim().isNotEmpty == true ? displayName! : username;

  factory BlogAuthor.fromJson(Map<String, dynamic> json) {
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
    return BlogAuthor(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
      displayName: fullName,
    );
  }
}

class BlogInfo {
  BlogInfo({required this.blogId, required this.title});

  final int blogId;
  final String title;

  factory BlogInfo.fromJson(Map<String, dynamic> json) {
    return BlogInfo(
      blogId: json['blog_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
    );
  }
}

class BlogCategory {
  BlogCategory({required this.categoryId, required this.title});

  final int categoryId;
  final String title;

  factory BlogCategory.fromJson(Map<String, dynamic> json) {
    return BlogCategory(
      categoryId: json['category_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
    );
  }
}

class BlogAttachment {
  BlogAttachment({this.thumbnailUrl, this.directUrl, this.attachDate});

  final String? thumbnailUrl;
  final String? directUrl;
  final int? attachDate;

  factory BlogAttachment.fromJson(Map<String, dynamic> json) {
    return BlogAttachment(
      thumbnailUrl: json['thumbnail_url']?.toString(),
      directUrl: json['direct_url']?.toString(),
      attachDate: json['attach_date'] as int?,
    );
  }
}

class BlogEntry {
  BlogEntry({
    required this.blogEntryId,
    this.title,
    this.messagePlainText,
    this.messageParsed,
    this.postDate,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.canReact = true,
    this.canComment = false,
    this.visitorReactionId,
    this.author,
    this.blog,
    this.category,
    this.coverImage,
    this.attachments = const [],
    this.viewUrl,
  });

  final int blogEntryId;
  final String? title;
  final String? messagePlainText;
  final String? messageParsed;
  final int? postDate;
  final int commentCount;
  final int reactionScore;
  final bool canReact;
  final bool canComment;
  final int? visitorReactionId;
  final BlogAuthor? author;
  final BlogInfo? blog;
  final BlogCategory? category;
  final BlogAttachment? coverImage;
  final List<BlogAttachment> attachments;
  final String? viewUrl;

  String? get thumbnailUrl {
    final cover = coverImage?.thumbnailUrl ?? coverImage?.directUrl;
    if (cover != null && cover.isNotEmpty) return cover;
    for (final attachment in attachments) {
      final url = attachment.thumbnailUrl ?? attachment.directUrl;
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String get previewBody {
    final plain = messagePlainText?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    return _stripHtml(messageParsed);
  }

  bool get previewHasMore {
    final plain = messagePlainText?.trim() ?? '';
    if (plain.length >= 280) return true;
    final parsed = _stripHtml(messageParsed);
    return parsed.length >= 280;
  }

  String get listPreviewBody {
    final body = previewBody;
    if (body.length <= 280) return body;
    return '${body.substring(0, 277).trimRight()}…';
  }

  static String _stripHtml(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  factory BlogEntry.fromJson(Map<String, dynamic> json) {
    final attachments = <BlogAttachment>[];
    if (json['Attachments'] is List) {
      for (final raw in json['Attachments'] as List) {
        if (raw is Map<String, dynamic>) {
          attachments.add(BlogAttachment.fromJson(raw));
        }
      }
    }

    BlogAttachment? cover;
    if (json['CoverImage'] is Map<String, dynamic>) {
      cover = BlogAttachment.fromJson(json['CoverImage'] as Map<String, dynamic>);
    }

    return BlogEntry(
      blogEntryId: json['blog_entry_id'] as int? ?? 0,
      title: json['title']?.toString(),
      messagePlainText: json['message_plain_text']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      postDate: json['post_date'] as int? ??
          json['publish_date'] as int? ??
          cover?.attachDate ??
          (attachments.isNotEmpty ? attachments.first.attachDate : null),
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      canReact: json['can_react'] as bool? ?? true,
      canComment: json['can_comment'] as bool? ?? false,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: json['User'] is Map<String, dynamic>
          ? BlogAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : null,
      blog: json['Blog'] is Map<String, dynamic>
          ? BlogInfo.fromJson(json['Blog'] as Map<String, dynamic>)
          : null,
      category: json['Category'] is Map<String, dynamic>
          ? BlogCategory.fromJson(json['Category'] as Map<String, dynamic>)
          : null,
      coverImage: cover,
      attachments: attachments,
      viewUrl: json['view_url']?.toString(),
    );
  }

  BlogEntry copyWith({int? reactionScore}) {
    return BlogEntry(
      blogEntryId: blogEntryId,
      title: title,
      messagePlainText: messagePlainText,
      messageParsed: messageParsed,
      postDate: postDate,
      commentCount: commentCount,
      reactionScore: reactionScore ?? this.reactionScore,
      canReact: canReact,
      author: author,
      blog: blog,
      category: category,
      coverImage: coverImage,
      attachments: attachments,
      viewUrl: viewUrl,
    );
  }
}

class BlogEntriesPage {
  BlogEntriesPage({required this.entries});

  final List<BlogEntry> entries;

  factory BlogEntriesPage.fromJson(Map<String, dynamic> json) {
    final list = <BlogEntry>[];
    void addFrom(dynamic raw) {
      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            list.add(BlogEntry.fromJson(item));
          }
        }
      }
    }

    addFrom(json['blogEntryItems']);
    addFrom(json['blogEntries']);
    addFrom(json['blogItems']);

    return BlogEntriesPage(entries: list);
  }
}
