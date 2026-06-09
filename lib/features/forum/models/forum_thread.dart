import 'package:kairete/features/forum/models/forum_node.dart';

class ForumAttachment {
  ForumAttachment({
    required this.url,
    this.imageUrl,
    this.fileName = '',
    this.isImage = false,
  });

  final String url;
  final String? imageUrl;
  final String fileName;
  final bool isImage;

  String? get displayImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl;
    if (isImage && url.isNotEmpty) return url;
    return null;
  }

  factory ForumAttachment.fromJson(Map<String, dynamic> json) {
    final direct = json['direct_url']?.toString() ??
        json['view_url']?.toString() ??
        json['url']?.toString() ??
        '';
    final thumb = json['thumbnail_url']?.toString() ??
        json['image_url']?.toString();
    final width = json['width'] as int? ?? 0;
    final height = json['height'] as int? ?? 0;
    final isImage = json['is_image'] == true ||
        json['isImage'] == true ||
        (width > 0 && height > 0) ||
        _looksLikeImage(direct) ||
        _looksLikeImage(thumb ?? '');

    return ForumAttachment(
      url: direct,
      imageUrl: thumb,
      fileName: json['filename']?.toString() ??
          json['file_name']?.toString() ??
          '',
      isImage: isImage,
    );
  }

  static bool _looksLikeImage(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }
}

class ForumThread {
  ForumThread({
    required this.threadId,
    required this.nodeId,
    this.title,
    this.postDate,
    this.replyCount = 0,
    this.viewCount = 0,
    this.firstPostId,
    this.firstPostReactionScore = 0,
    this.messagePlainText,
    this.messageParsed,
    this.author,
    this.forumTitle,
    this.viewUrl,
    this.canReact = true,
    this.tags = const [],
    this.attachments = const [],
    this.canEdit = false,
    this.canDelete = false,
  });

  final int threadId;
  final int nodeId;
  final String? title;
  final int? postDate;
  final int replyCount;
  final int viewCount;
  final int? firstPostId;
  final int firstPostReactionScore;
  final String? messagePlainText;
  final String? messageParsed;
  final ForumAuthor? author;
  final String? forumTitle;
  final String? viewUrl;
  final bool canReact;
  final List<String> tags;
  final List<ForumAttachment> attachments;
  final bool canEdit;
  final bool canDelete;

  int get commentCount => replyCount;

  String get previewBody {
    final plain = messagePlainText?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    return _stripHtml(messageParsed);
  }

  bool get previewHasMore {
    final body = previewBody;
    if (body.isEmpty) return true;
    return body.length >= 280;
  }

  String get listPreviewBody {
    final body = previewBody;
    if (body.isEmpty) return '';
    if (body.length <= 280) return body;
    return '${body.substring(0, 277).trimRight()}…';
  }

  bool get listPreviewNeedsDetailLink =>
      previewBody.isEmpty || previewHasMore;

  static String _stripHtml(String? html) {
    if (html == null) return '';
    return html
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static int? _firstPostIdFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['post_id'] as int?;
    }
    return null;
  }

  static int _firstPostReactionScoreFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['reaction_score'] as int? ?? 0;
    }
    return 0;
  }

  static String? _firstPostMessageFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['message']?.toString();
    }
    return null;
  }

  static String? _firstPostParsedFromJson(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return raw['message_parsed']?.toString();
    }
    return null;
  }

  static List<ForumAttachment> parseAttachments(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(ForumAttachment.fromJson)
        .where((a) => a.url.isNotEmpty || (a.imageUrl?.isNotEmpty ?? false))
        .toList();
  }

  static List<String> parseTags(Map<String, dynamic> json) {
    final tags = <String>[];
    final rawTags = json['tags'];
    if (rawTags is List) {
      for (final tag in rawTags) {
        if (tag is String && tag.trim().isNotEmpty) {
          tags.add(tag.trim());
        } else if (tag is Map) {
          final label = tag['tag']?.toString() ?? tag['text']?.toString();
          if (label != null && label.trim().isNotEmpty) tags.add(label.trim());
        }
      }
    }
    final tagList = json['tag_list'];
    if (tagList is List) {
      for (final tag in tagList) {
        if (tag is String && tag.trim().isNotEmpty) tags.add(tag.trim());
      }
    }
    return tags;
  }

  factory ForumThread.fromJson(Map<String, dynamic> json) {
    final forum = json['Forum'];
    String? forumTitle;
    if (forum is Map<String, dynamic>) {
      forumTitle = forum['title']?.toString();
    }

    return ForumThread(
      threadId: json['thread_id'] as int? ?? 0,
      nodeId: json['node_id'] as int? ?? 0,
      title: json['title']?.toString(),
      postDate: json['post_date'] as int? ?? json['last_post_date'] as int?,
      replyCount: json['reply_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      firstPostId: json['first_post_id'] as int? ??
          _firstPostIdFromJson(json['FirstPost']),
      firstPostReactionScore: json['first_post_reaction_score'] as int? ??
          _firstPostReactionScoreFromJson(json['FirstPost']),
      messagePlainText: json['message']?.toString() ??
          _firstPostMessageFromJson(json['FirstPost']),
      messageParsed: json['message_parsed']?.toString() ??
          _firstPostParsedFromJson(json['FirstPost']),
      author: json['User'] is Map<String, dynamic>
          ? ForumAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : ForumAuthor(
              userId: json['user_id'] as int? ?? 0,
              username: json['username']?.toString() ?? '',
            ),
      forumTitle: forumTitle,
      viewUrl: json['view_url']?.toString(),
      canReact: json['can_react'] as bool? ?? true,
      tags: parseTags(json),
      attachments: parseAttachments(json['Attachments']) +
          parseAttachments(json['FirstPost'] is Map
              ? (json['FirstPost'] as Map)['Attachments']
              : null),
      canEdit: json['can_edit'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? json['can_soft_delete'] as bool? ?? false,
    );
  }

  ForumThread copyWith({
    String? messagePlainText,
    String? messageParsed,
    String? forumTitle,
    bool? canReact,
    int? firstPostReactionScore,
    List<String>? tags,
    List<ForumAttachment>? attachments,
    bool? canEdit,
    bool? canDelete,
  }) {
    return ForumThread(
      threadId: threadId,
      nodeId: nodeId,
      title: title,
      postDate: postDate,
      replyCount: replyCount,
      viewCount: viewCount,
      firstPostId: firstPostId,
      firstPostReactionScore:
          firstPostReactionScore ?? this.firstPostReactionScore,
      messagePlainText: messagePlainText ?? this.messagePlainText,
      messageParsed: messageParsed ?? this.messageParsed,
      author: author,
      forumTitle: forumTitle ?? this.forumTitle,
      viewUrl: viewUrl,
      canReact: canReact ?? this.canReact,
      tags: tags ?? this.tags,
      attachments: attachments ?? this.attachments,
      canEdit: canEdit ?? this.canEdit,
      canDelete: canDelete ?? this.canDelete,
    );
  }
}

class ForumThreadsPage {
  ForumThreadsPage({required this.threads});

  final List<ForumThread> threads;

  factory ForumThreadsPage.fromJson(Map<String, dynamic> json) {
    final list = <ForumThread>[];
    if (json['threads'] is List) {
      for (final raw in json['threads'] as List) {
        if (raw is Map<String, dynamic>) {
          list.add(ForumThread.fromJson(raw));
        }
      }
    }
    return ForumThreadsPage(threads: list);
  }
}

class ForumPost {
  ForumPost({
    required this.postId,
    required this.threadId,
    this.messagePlainText,
    this.messageParsed,
    this.postDate,
    this.reactionScore = 0,
    this.isFirstPost = false,
    this.author,
    this.canReact = true,
    this.attachments = const [],
    this.canEdit = false,
    this.canDelete = false,
  });

  final int postId;
  final int threadId;
  final String? messagePlainText;
  final String? messageParsed;
  final int? postDate;
  final int reactionScore;
  final bool isFirstPost;
  final ForumAuthor? author;
  final bool canReact;
  final List<ForumAttachment> attachments;
  final bool canEdit;
  final bool canDelete;

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      postId: json['post_id'] as int? ?? 0,
      threadId: json['thread_id'] as int? ?? 0,
      messagePlainText: json['message']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      postDate: json['post_date'] as int?,
      reactionScore: json['reaction_score'] as int? ?? 0,
      isFirstPost: json['is_first_post'] as bool? ?? false,
      canReact: json['can_react'] as bool? ?? true,
      attachments: ForumThread.parseAttachments(json['Attachments']),
      canEdit: json['can_edit'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? json['can_soft_delete'] as bool? ?? false,
      author: json['User'] is Map<String, dynamic>
          ? ForumAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : ForumAuthor(
              userId: json['user_id'] as int? ?? 0,
              username: json['username']?.toString() ?? '',
            ),
    );
  }
}

class ForumPostsPage {
  ForumPostsPage({
    required this.posts,
    this.pagination,
  });

  final List<ForumPost> posts;
  final ForumPagination? pagination;

  bool get hasMore {
    final p = pagination;
    if (p == null) return false;
    return p.currentPage < p.lastPage;
  }

  factory ForumPostsPage.fromJson(Map<String, dynamic> json) {
    final list = <ForumPost>[];
    if (json['posts'] is List) {
      for (final raw in json['posts'] as List) {
        if (raw is Map<String, dynamic>) {
          list.add(ForumPost.fromJson(raw));
        }
      }
    }
    return ForumPostsPage(
      posts: list,
      pagination: json['pagination'] is Map<String, dynamic>
          ? ForumPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ForumPagination {
  ForumPagination({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  factory ForumPagination.fromJson(Map<String, dynamic> json) {
    return ForumPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 20,
    );
  }
}
