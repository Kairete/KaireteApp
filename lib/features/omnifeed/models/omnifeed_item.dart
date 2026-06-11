import 'package:kairete/core/models/feed_attachment.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/media/models/media_item.dart';

/// ID composto feed mobile (allineato a OmniFeed ItemIdCodec).
class OmnifeedItemId {
  OmnifeedItemId._();

  static const multiplier = 1000000000;
  static const typeProfilePost = 1;
  static const typeThread = 2;
  static const typeGroupPost = 3;
  static const typeBlogPost = 4;
  static const typeMedia = 5;

  static int encode(int type, int nativeId) => type * multiplier + nativeId;
}

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
    this.contentId,
    this.contentTitle,
    this.messagePlainText,
    this.messageParsed,
    this.itemDate,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.visitorReactionId,
    this.author,
    this.categoryLabel,
    this.blogLabel,
    this.blogId,
    this.forumId,
    this.albumId,
    this.albumLabel,
    this.mediaCategoryId,
    this.mediaThumbnailUrl,
    this.mediaUrl,
    this.mediaType,
    this.viewUrl,
    this.groupId,
    this.tags = const [],
    this.attachments = const [],
  });

  final int itemId;
  final String? contentType;
  final int? contentId;
  final String? contentTitle;
  final String? messagePlainText;
  final String? messageParsed;
  final int? itemDate;
  final int commentCount;
  final int reactionScore;
  final int? visitorReactionId;
  final OmnifeedAuthor? author;
  final String? categoryLabel;
  final String? blogLabel;
  final int? blogId;
  final int? forumId;
  final int? albumId;
  final String? albumLabel;
  final int? mediaCategoryId;
  final String? mediaThumbnailUrl;
  final String? mediaUrl;
  final String? mediaType;
  final String? viewUrl;
  final int? groupId;
  final List<String> tags;
  final List<FeedAttachment> attachments;

  List<String> get imageAttachmentUrls =>
      attachments.map((a) => a.displayImageUrl).whereType<String>().toList();

  /// Post sul profilo/newsfeed: solo testo nel body, senza titolo modulo.
  bool get isPlainFeedPost => contentType == 'profile_post';

  /// Thread, blog, gruppo, articolo, ecc.: titolo nel body sotto l'header.
  bool get showsModuleTitle =>
      !isPlainFeedPost && (contentTitle?.trim().isNotEmpty ?? false);

  String get moduleTitle => contentTitle?.trim() ?? '';

  /// Forum, blog, album media, gruppo, ecc. accanto al nickname nell'header.
  String? get headerModuleLabel {
    if (isPlainFeedPost) return null;
    if (contentType == 'ubs_blog_entry') {
      final blog = blogLabel?.trim();
      if (blog != null && blog.isNotEmpty) return blog;
    }
    if (contentType == 'xfmg_media') {
      final album = albumLabel?.trim();
      if (album != null && album.isNotEmpty) return album;
    }
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
    return '';
  }

  String get listPreviewBody {
    final body = displayBody;
    if (body.isEmpty) return '';
    if (body.length <= 280) return body;
    return '${body.substring(0, 277).trimRight()}…';
  }

  bool get previewHasMore {
    final body = displayBody;
    if (body.isEmpty) return contentType == 'xfmg_media';
    return body.length >= 280;
  }

  bool get isMediaVideo =>
      mediaType == 'video' ||
      mediaType == 'video_upload' ||
      (mediaUrl?.contains('.mp4') ?? false) ||
      (mediaUrl?.contains('.webm') ?? false) ||
      (mediaUrl?.contains('.mov') ?? false);

  bool get isMediaAudio =>
      mediaType == 'audio' ||
      mediaType == 'audio_upload' ||
      (mediaUrl?.contains('.mp3') ?? false) ||
      (mediaUrl?.contains('.m4a') ?? false);

  bool get isMediaPlayable => isMediaVideo || isMediaAudio;

  MediaItem toMediaPreview() {
    final user = author;
    return MediaItem(
      mediaId: contentId ?? 0,
      title: contentTitle,
      description: messagePlainText,
      mediaDate: itemDate,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      thumbnailUrl: mediaThumbnailUrl,
      author: user == null
          ? null
          : MediaAuthor(
              userId: user.userId,
              username: user.username,
              avatarUrl: user.avatarUrl,
              displayName: user.displayName,
            ),
      album: albumId != null && albumId! > 0
          ? MediaAlbumRef(albumId: albumId!, title: albumLabel ?? '')
          : null,
      category: mediaCategoryId != null && mediaCategoryId! > 0
          ? MediaCategoryRef(
              categoryId: mediaCategoryId!,
              title: categoryLabel ?? '',
            )
          : null,
      tags: tags,
      viewUrl: viewUrl,
    );
  }

  String? get mediaHeroUrl {
    final thumb = mediaThumbnailUrl?.trim();
    if (thumb != null && thumb.isNotEmpty) return thumb;
    if (!isMediaPlayable) {
      final direct = mediaUrl?.trim();
      if (direct != null && direct.isNotEmpty) return direct;
    }
    return null;
  }

  bool get listPreviewNeedsDetailLink =>
      displayBody.isEmpty || previewHasMore || contentType == 'xfmg_media';

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

  factory OmnifeedItem.fromBlogEntry(BlogEntry entry) {
    final author = entry.author;
    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(
        OmnifeedItemId.typeBlogPost,
        entry.blogEntryId,
      ),
      contentType: 'ubs_blog_entry',
      contentId: entry.blogEntryId,
      contentTitle: entry.title,
      messagePlainText: entry.messagePlainText,
      messageParsed: entry.messageParsed,
      itemDate: entry.postDate,
      commentCount: entry.commentCount,
      reactionScore: entry.reactionScore,
      visitorReactionId: entry.visitorReactionId,
      author: author == null
          ? null
          : OmnifeedAuthor(
              userId: author.userId,
              username: author.username,
              avatarUrl: author.avatarUrl,
              displayName: author.displayName,
            ),
      blogLabel: entry.blog?.title,
      blogId: entry.blog?.blogId,
      categoryLabel: entry.category?.title,
      viewUrl: entry.viewUrl,
      attachments: entry.attachments
          .map(
            (a) => FeedAttachment(
              thumbnailUrl: a.thumbnailUrl,
              directUrl: a.directUrl,
            ),
          )
          .toList(),
    );
  }

  factory OmnifeedItem.fromMediaItem(MediaItem entry) {
    final author = entry.author;
    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(
        OmnifeedItemId.typeMedia,
        entry.mediaId,
      ),
      contentType: 'xfmg_media',
      contentId: entry.mediaId,
      contentTitle: entry.title,
      messagePlainText: entry.description,
      messageParsed: entry.description,
      itemDate: entry.mediaDate,
      commentCount: entry.commentCount,
      reactionScore: entry.reactionScore,
      visitorReactionId: entry.visitorReactionId,
      author: author == null
          ? null
          : OmnifeedAuthor(
              userId: author.userId,
              username: author.username,
              avatarUrl: author.avatarUrl,
              displayName: author.displayName,
            ),
      albumLabel: entry.album?.title,
      albumId: entry.album?.albumId,
      categoryLabel: entry.category?.title,
      mediaCategoryId: entry.category?.categoryId,
      mediaThumbnailUrl: entry.thumbnailUrl,
      mediaUrl: entry.mediaUrl,
      mediaType: entry.mediaType,
      viewUrl: entry.viewUrl,
      tags: entry.tags,
    );
  }

  factory OmnifeedItem.fromForumThread(ForumThread thread) {
    final author = thread.author;
    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(
        OmnifeedItemId.typeThread,
        thread.threadId,
      ),
      contentType: 'thread',
      contentId: thread.threadId,
      contentTitle: thread.title,
      messagePlainText: thread.messagePlainText,
      messageParsed: thread.messageParsed,
      itemDate: thread.postDate,
      commentCount: thread.commentCount,
      reactionScore: thread.firstPostReactionScore,
      author: author == null
          ? null
          : OmnifeedAuthor(
              userId: author.userId,
              username: author.username,
              avatarUrl: author.avatarUrl,
              displayName: author.displayName,
            ),
      categoryLabel: thread.forumTitle,
      forumId: thread.nodeId,
      viewUrl: thread.viewUrl,
      tags: thread.tags,
      attachments: thread.attachments
          .map(
            (a) => FeedAttachment(
              thumbnailUrl: a.imageUrl,
              directUrl: a.url,
              filename: a.fileName,
            ),
          )
          .toList(),
    );
  }

  factory OmnifeedItem.fromGroupPostApi(Map<String, dynamic> json) {
    final postId = json['group_post_id'] as int? ?? 0;
    final user = json['User'];
    final group = json['Group'];
    String? groupName;
    int? groupId = json['group_id'] as int?;
    if (group is Map<String, dynamic>) {
      groupName = group['name']?.toString() ?? group['title']?.toString();
      groupId ??= group['group_id'] as int?;
    }

    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(OmnifeedItemId.typeGroupPost, postId),
      contentType: 'tl_group_post',
      contentId: postId,
      contentTitle: groupName,
      messagePlainText: json['message_plain_text']?.toString() ??
          json['message']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      itemDate: json['post_date'] as int?,
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      author: user is Map<String, dynamic>
          ? OmnifeedAuthor.fromJson(user)
          : OmnifeedAuthor(
              userId: json['user_id'] as int? ?? 0,
              username: json['username']?.toString() ?? '',
            ),
      categoryLabel: groupName,
      groupId: groupId,
      viewUrl: json['view_url']?.toString(),
    );
  }

  factory OmnifeedItem.fromProfilePostApi(Map<String, dynamic> json) {
    final postId = json['profile_post_id'] as int? ?? 0;
    final user = json['User'];
    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(OmnifeedItemId.typeProfilePost, postId),
      contentType: 'profile_post',
      contentId: postId,
      messagePlainText: json['message']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      itemDate: json['post_date'] as int?,
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      author: user is Map<String, dynamic>
          ? OmnifeedAuthor.fromJson(user)
          : OmnifeedAuthor(
              userId: json['user_id'] as int? ?? 0,
              username: json['username']?.toString() ?? '',
            ),
      viewUrl: json['view_url']?.toString(),
      attachments: FeedAttachment.parseList(json['Attachments']),
    );
  }

  factory OmnifeedItem.fromJson(Map<String, dynamic> json) {
    final content = json['Content'] as Map<String, dynamic>?;
    final profile = json['ProfilePost'] as Map<String, dynamic>?;
    final group = json['GroupPost'] as Map<String, dynamic>?;

    int? groupId = json['group_id'] as int?;
    if (groupId == null && group?['Group'] is Map) {
      groupId = (group!['Group'] as Map)['group_id'] as int?;
    }

    String? category;
    if (content?['Category'] is Map) {
      category = (content!['Category'] as Map)['title']?.toString();
    } else if (profile?['Category'] is Map) {
      category = (profile!['Category'] as Map)['title']?.toString();
    } else if (group?['Group'] is Map) {
      category = (group!['Group'] as Map)['name']?.toString();
    }

    String? blogTitle;
    int? blogId;
    for (final source in [
      json['Blog'],
      content?['Blog'],
      json['BlogEntryItem'] is Map ? (json['BlogEntryItem'] as Map)['Blog'] : null,
    ]) {
      if (source is Map) {
        final title = source['title']?.toString().trim();
        if (title != null && title.isNotEmpty) {
          blogTitle = title;
        }
        final id = source['blog_id'] as int?;
        if (id != null && id > 0) blogId = id;
        if (blogTitle != null && blogId != null) break;
      }
    }
    int? forumId;
    if (content?['Category'] is Map) {
      forumId = (content!['Category'] as Map)['node_id'] as int?;
    }
    if (category == null) {
      for (final source in [
        json['Category'],
        content?['Category'],
        json['BlogEntryItem'] is Map
            ? (json['BlogEntryItem'] as Map)['Category']
            : null,
        json['Media'] is Map ? (json['Media'] as Map)['Category'] : null,
      ]) {
        if (source is Map) {
          final title = source['title']?.toString().trim();
          if (title != null && title.isNotEmpty) {
            category = title;
            break;
          }
        }
      }
    }

    String? albumTitle;
    int? albumId;
    int? mediaCategoryId;
    for (final source in [json['Category'], content?['Category']]) {
      if (source is Map) {
        final id = source['category_id'] as int?;
        if (id != null && id > 0) mediaCategoryId = id;
      }
    }
    for (final source in [json['Album'], content?['Album']]) {
      if (source is Map) {
        final title = source['title']?.toString().trim();
        if (title != null && title.isNotEmpty) albumTitle = title;
        final id = source['album_id'] as int?;
        if (id != null && id > 0) albumId = id;
        if (albumTitle != null && albumId != null) break;
      }
    }
    if (albumId == null && json['album_id'] is int && (json['album_id'] as int) > 0) {
      albumId = json['album_id'] as int;
    }
    if ((albumTitle == null || albumTitle.isEmpty) && albumId != null) {
      final container = json['container_name']?.toString().trim();
      if (container != null && container.isNotEmpty) {
        albumTitle = container;
      }
    }

    final mediaThumb = json['thumbnail_url']?.toString() ??
        content?['thumbnail_url']?.toString();
    final mediaDirect = json['media_url']?.toString() ??
        content?['media_url']?.toString();
    final mediaKind = json['media_type']?.toString() ??
        content?['media_type']?.toString();

    return OmnifeedItem(
      itemId: json['item_id'] as int? ?? 0,
      contentType: json['content_type']?.toString(),
      contentId: json['content_id'] as int?,
      contentTitle: json['ContentTitle']?.toString(),
      messagePlainText: json['message_plain_text']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      itemDate: json['item_date'] as int?,
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: json['User'] is Map
          ? OmnifeedAuthor.fromJson(json['User'] as Map<String, dynamic>)
          : (json['user_id'] is int
              ? OmnifeedAuthor(
                  userId: json['user_id'] as int,
                  username: json['username']?.toString() ?? '',
                )
              : null),
      categoryLabel: category,
      blogLabel: blogTitle,
      blogId: blogId,
      forumId: forumId,
      albumId: albumId,
      albumLabel: albumTitle,
      mediaCategoryId: mediaCategoryId,
      mediaThumbnailUrl: mediaThumb,
      mediaUrl: mediaDirect,
      mediaType: mediaKind,
      viewUrl: json['view_url']?.toString(),
      groupId: groupId,
      tags: _parseTags(json['tags']),
      attachments: FeedAttachment.parseList(json['Attachments']),
    );
  }

  static List<String> _parseTags(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((tag) {
          if (tag is String) return tag.trim();
          if (tag is Map) return tag['tag']?.toString().trim() ?? '';
          return '';
        })
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  OmnifeedItem copyWith({int? reactionScore, int? visitorReactionId}) {
    return OmnifeedItem(
      itemId: itemId,
      contentType: contentType,
      contentId: contentId,
      contentTitle: contentTitle,
      messagePlainText: messagePlainText,
      messageParsed: messageParsed,
      itemDate: itemDate,
      commentCount: commentCount,
      reactionScore: reactionScore ?? this.reactionScore,
      visitorReactionId: visitorReactionId ?? this.visitorReactionId,
      author: author,
      categoryLabel: categoryLabel,
      blogLabel: blogLabel,
      blogId: blogId,
      forumId: forumId,
      viewUrl: viewUrl,
      groupId: groupId,
      tags: tags,
      attachments: attachments,
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
