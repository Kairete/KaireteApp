import 'package:flutter/material.dart';
import 'package:kairete/core/models/feed_attachment.dart';
import 'package:kairete/core/utils/json_parse.dart';
import 'package:kairete/features/blog/models/blog_entry.dart';
import 'package:kairete/features/feed/models/author_signature_fields.dart';
import 'package:kairete/features/feed/widgets/feed_link_preview.dart';
import 'package:kairete/features/forum/models/forum_thread.dart';
import 'package:kairete/features/media/models/media_item.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_tab.dart';

/// ID composto feed mobile (allineato a OmniFeed ItemIdCodec).
class OmnifeedItemId {
  OmnifeedItemId._();

  static const multiplier = 1000000000;
  static const typeProfilePost = 1;
  static const typeThread = 2;
  static const typeGroupPost = 3;
  static const typeBlogPost = 4;
  static const typeMedia = 5;
  static const typeSocialNewsArticle = 6;

  static int encode(int type, int nativeId) => type * multiplier + nativeId;

  static int decodeType(int itemId) => itemId ~/ multiplier;

  static int decodeNativeId(int itemId) => itemId % multiplier;
}

class OmnifeedFeed {
  OmnifeedFeed({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.mode,
    this.sort,
    this.tab,
    this.criteriaDebug = const {},
    this.omnifeedVersion,
  });

  final List<OmnifeedItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  /// Mode effettivo usato dal server (tab_key ACP o legacy).
  final String? mode;
  /// Sort effettivo usato dal server (da sort_mode del tab).
  final String? sort;
  /// Tab ACP usato dal server (criteri inclusi), se presente.
  final OmnifeedTab? tab;
  /// Diagnostica server (followers/following counts, flag criteri).
  final Map<String, dynamic> criteriaDebug;
  /// Versione addon OmniFeed sul server (per verificare l’upgrade).
  final String? omnifeedVersion;

  bool get hasMorePages => currentPage < lastPage;

  factory OmnifeedFeed.fromJson(Map<String, dynamic> json) {
    final raw = json['newsfeedItems'] as List<dynamic>? ?? [];
    final pagination = json['pagination'];
    var currentPage = 1;
    var lastPage = 1;
    var total = 0;
    if (pagination is Map) {
      currentPage = JsonParse.intValue(pagination['current_page'], fallback: 1);
      lastPage = JsonParse.intValue(pagination['last_page'], fallback: 1);
      total = JsonParse.intValue(pagination['total']);
    }
    final mode = (json['mode'] as String?)?.trim();
    final sort = (json['sort'] as String?)?.trim();
    OmnifeedTab? tab;
    final tabRaw = json['tab'];
    if (tabRaw is Map) {
      tab = OmnifeedTab.fromJson(Map<String, dynamic>.from(tabRaw));
    }
    final debugRaw = json['criteria_debug'];
    final version = (json['omnifeed_version'] as String?)?.trim();
    return OmnifeedFeed(
      items: raw
          .whereType<Map>()
          .map((e) => OmnifeedItem.fromFeedJson(Map<String, dynamic>.from(e)))
          .toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      mode: (mode != null && mode.isNotEmpty) ? mode : null,
      sort: (sort != null && sort.isNotEmpty) ? sort : null,
      tab: tab,
      criteriaDebug: debugRaw is Map
          ? Map<String, dynamic>.from(debugRaw)
          : const {},
      omnifeedVersion:
          (version != null && version.isNotEmpty) ? version : null,
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
    this.activityDate,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.visitorReactionId,
    this.isBookmarked = false,
    this.isHighlighted = false,
    this.canHighlight = false,
    this.highlightScope,
    this.shareCount = 0,
    this.isShare = false,
    this.sharedItem,
    this.author,
    this.categoryLabel,
    this.categoryHeaderColor,
    this.blogLabel,
    this.blogId,
    this.blogCategoryId,
    this.forumId,
    this.albumId,
    this.albumLabel,
    this.mediaCategoryId,
    this.mediaThumbnailUrl,
    this.mediaUrl,
    this.mediaType,
    this.mediaDurationSeconds,
    this.viewUrl,
    this.groupId,
    this.tags = const [],
    this.attachments = const [],
    this.linkPreviews = const [],
    this.isPaidContent = false,
    this.canViewFull = true,
    this.previewCtaLabel,
  });

  final int itemId;
  final String? contentType;
  final int? contentId;
  final String? contentTitle;
  final String? messagePlainText;
  final String? messageParsed;
  final int? itemDate;
  /// Data usata per sort "ultimo commento" (dal server). Fallback: [itemDate].
  final int? activityDate;
  final int commentCount;
  final int reactionScore;
  final int? visitorReactionId;
  final bool isBookmarked;
  final bool isHighlighted;
  final bool canHighlight;
  final String? highlightScope;
  final int shareCount;
  final bool isShare;
  final OmnifeedItem? sharedItem;
  final OmnifeedAuthor? author;
  final String? categoryLabel;
  final String? categoryHeaderColor;
  final String? blogLabel;
  final int? blogId;
  final int? blogCategoryId;
  final int? forumId;
  final int? albumId;
  final String? albumLabel;
  final int? mediaCategoryId;
  final String? mediaThumbnailUrl;
  final String? mediaUrl;
  final String? mediaType;
  final int? mediaDurationSeconds;
  final String? viewUrl;
  final int? groupId;
  final List<String> tags;
  final List<FeedAttachment> attachments;
  final List<FeedLinkPreviewData> linkPreviews;
  final bool isPaidContent;
  final bool canViewFull;
  final String? previewCtaLabel;

  String? get continueLabel {
    final cta = previewCtaLabel?.trim();
    if (cta != null && cta.isNotEmpty) return cta;
    return null;
  }

  List<String> get imageAttachmentUrls =>
      attachments.map((a) => a.displayImageUrl).whereType<String>().toList();

  /// Post sul profilo/newsfeed: solo testo nel body, senza titolo modulo.
  bool get isPlainFeedPost => resolvedContentType == 'profile_post';

  /// Tipi di contenuto con commenti inline nel feed.
  bool get supportsInlineFeedComments {
    if (nativeContentId <= 0 && itemId <= 0) return false;
    switch (resolvedContentType) {
      case 'profile_post':
      case 'tl_group_post':
      case 'ubs_blog_entry':
      case 'thread':
      case 'xfmg_media':
      case 'social_news_article':
        return true;
      default:
        return false;
    }
  }

  String get resolvedContentType {
    final explicit = contentType?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    switch (OmnifeedItemId.decodeType(itemId)) {
      case OmnifeedItemId.typeProfilePost:
        return 'profile_post';
      case OmnifeedItemId.typeThread:
        return 'thread';
      case OmnifeedItemId.typeGroupPost:
        return 'tl_group_post';
      case OmnifeedItemId.typeBlogPost:
        return 'ubs_blog_entry';
      case OmnifeedItemId.typeMedia:
        return 'xfmg_media';
      case OmnifeedItemId.typeSocialNewsArticle:
        return 'social_news_article';
      default:
        return explicit ?? '';
    }
  }

  int get nativeContentId {
    final id = contentId ?? 0;
    if (id > 0) return id;
    if (itemId > 0) return OmnifeedItemId.decodeNativeId(itemId);
    return 0;
  }

  /// Thread, blog, gruppo, articolo, ecc.: titolo nel body sotto l'header.
  bool get showsModuleTitle =>
      !isPlainFeedPost &&
      contentType != 'tl_group_post' &&
      contentType != 'social_news_article' &&
      (contentTitle?.trim().isNotEmpty ?? false);

  Color get socialNewsHeroColor {
    var hex = (categoryHeaderColor ?? '#333333').trim();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xFF333333);
    return Color(value);
  }

  String get moduleTitle => contentTitle?.trim() ?? '';

  /// Titolo album per l'header media (`nickname > album`), mai la categoria.
  String? get headerAlbumLabel {
    final album = albumLabel?.trim();
    if (album != null && album.isNotEmpty) return album;
    return null;
  }

  /// Copertina blog nel feed (titolo → immagine → anteprima).
  String? get blogCoverUrl {
    if (contentType != 'ubs_blog_entry') return null;
    final thumb = mediaThumbnailUrl?.trim();
    if (thumb != null && thumb.isNotEmpty) return thumb;
    if (imageAttachmentUrls.isNotEmpty) return imageAttachmentUrls.first;
    return null;
  }

  /// Forum, blog, album media, gruppo, ecc. accanto al nickname nell'header.
  String? get headerModuleLabel {
    if (contentType == 'social_news_article') return null;
    if (isPlainFeedPost) return null;
    if (contentType == 'tl_group_post') {
      final group = categoryLabel?.trim();
      if (group != null && group.isNotEmpty) return group;
      final title = contentTitle?.trim();
      if (title != null && title.isNotEmpty) return title;
      return null;
    }
    if (contentType == 'ubs_blog_entry') {
      final blog = blogLabel?.trim();
      if (blog != null && blog.isNotEmpty) return blog;
    }
    if (contentType == 'xfmg_media') {
      return headerAlbumLabel;
    }
    if (contentType == 'thread') {
      final forum = categoryLabel?.trim();
      if (forum != null && forum.isNotEmpty) return forum;
      return null;
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
    var text = (plain != null && plain.isNotEmpty)
        ? plain
        : (messageParsed?.replaceAll(RegExp(r'<[^>]*>'), ' ').trim() ?? '');
    if (text.isEmpty) return '';

    // Share: commento utente sopra; originale nella card annidata.
    if (isShare || sharedItem != null) {
      final quoteAt = text.toUpperCase().indexOf('[QUOTE');
      if (quoteAt >= 0) {
        text = text.substring(0, quoteAt).trim();
      }
      // Togli URL finali lasciati dalle share legacy.
      text = text.replaceAll(RegExp(r'\s*https?:\/\/\S+\s*$'), '').trim();
    }
    return text;
  }

  String get listPreviewBody {
    var body = displayBody;
    if (body.isEmpty) return '';
    for (final preview in linkPreviews) {
      if (preview.url.isEmpty) continue;
      body = body.replaceAll(preview.url, '').trim();
    }
    body = body.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    if (body.isEmpty) return '';
    if (body.length <= 280) return body;
    return '${body.substring(0, 277).trimRight()}…';
  }

  bool get previewHasMore {
    if (isPaidContent && !canViewFull) return true;
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
      durationSeconds: mediaDurationSeconds,
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
      displayBody.isEmpty ||
      previewHasMore ||
      contentType == 'xfmg_media' ||
      (isPaidContent && !canViewFull);

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
              signatureHtml: author.signatureHtml,
              signaturePlain: author.signaturePlain,
              contentShowSignature: author.contentShowSignature,
            ),
      blogLabel: entry.blog?.title,
      blogId: entry.blog?.blogId,
      categoryLabel: entry.category?.title,
      mediaThumbnailUrl: entry.thumbnailUrl,
      viewUrl: entry.viewUrl,
      tags: entry.tags,
      attachments: entry.attachments
          .map(
            (a) => FeedAttachment(
              thumbnailUrl: a.thumbnailUrl,
              directUrl: a.directUrl,
            ),
          )
          .toList(),
      isPaidContent: entry.isPaidContent,
      canViewFull: entry.canViewFull,
      previewCtaLabel: entry.previewCtaLabel,
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
              signatureHtml: author.signatureHtml,
              signaturePlain: author.signaturePlain,
              contentShowSignature: author.contentShowSignature,
            ),
      albumLabel: entry.album?.title,
      albumId: entry.album?.albumId,
      categoryLabel: entry.category?.title,
      mediaCategoryId: entry.category?.categoryId,
      mediaThumbnailUrl: entry.thumbnailUrl,
      mediaUrl: entry.mediaUrl,
      mediaType: entry.mediaType,
      mediaDurationSeconds: entry.durationSeconds,
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
              signatureHtml: author.signatureHtml,
              signaturePlain: author.signaturePlain,
              contentShowSignature: author.contentShowSignature,
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
    var postId = JsonParse.intValue(json['profile_post_id']);
    if (postId <= 0) {
      postId = JsonParse.intValue(json['post_id']);
    }
    final userMap = _userMapFromApiJson(json);
    final authorId = userMap != null
        ? JsonParse.intValue(userMap['user_id'])
        : JsonParse.intValue(json['user_id']);
    final authorName =
        userMap?['username']?.toString() ?? json['username']?.toString() ?? '';
    return OmnifeedItem(
      itemId: OmnifeedItemId.encode(OmnifeedItemId.typeProfilePost, postId),
      contentType: 'profile_post',
      contentId: postId,
      messagePlainText: json['message']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      itemDate: JsonParse.intOrNull(json['post_date']),
      commentCount: JsonParse.intValue(json['comment_count']),
      reactionScore: JsonParse.intValue(json['reaction_score']),
      author: userMap != null
          ? OmnifeedAuthor.fromJson(userMap)
          : OmnifeedAuthor(userId: authorId, username: authorName),
      viewUrl: json['view_url']?.toString(),
      attachments: FeedAttachment.parseList(json['Attachments']),
    );
  }

  static Map<String, dynamic>? _userMapFromApiJson(Map<String, dynamic> json) {
    for (final key in ['User', 'user', 'Poster']) {
      final value = json[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Normalizza payload feed (nested ProfilePost, item_id mancante, ecc.).
  static Map<String, dynamic> normalizeFeedItemJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);

    final profile = map['ProfilePost'];
    if (profile is Map) {
      final post = Map<String, dynamic>.from(profile);
      map['content_type'] ??= 'profile_post';
      final postId = JsonParse.intValue(post['profile_post_id']);
      if (postId > 0) {
        map['profile_post_id'] ??= postId;
        map['content_id'] ??= postId;
      }
      map['message_plain_text'] ??= post['message']?.toString();
      map['message_parsed'] ??=
          post['message_parsed']?.toString() ?? post['message']?.toString();
      map['item_date'] ??= post['post_date'];
      map['comment_count'] ??= post['comment_count'];
      map['reaction_score'] ??= post['reaction_score'];
      if (map['User'] == null && post['User'] is Map) {
        map['User'] = post['User'];
      }
    }

    final resolvedId = resolveItemId(
      contentType: map['content_type']?.toString(),
      rawItemId: JsonParse.intValue(map['item_id']),
      contentId: JsonParse.intOrNull(map['content_id']),
      profilePostId: JsonParse.intValue(map['profile_post_id']),
    );
    if (resolvedId > 0) {
      map['item_id'] = resolvedId;
      map['content_id'] ??= OmnifeedItemId.decodeNativeId(resolvedId);
    }

    return map;
  }

  static int resolveItemId({
    required String? contentType,
    required int rawItemId,
    required int? contentId,
    int profilePostId = 0,
  }) {
    if (rawItemId > 0) return rawItemId;

    final type = contentType ?? '';
    int nativeId = contentId ?? 0;
    int encodedType = 0;

    switch (type) {
      case 'profile_post':
        nativeId = nativeId > 0 ? nativeId : profilePostId;
        encodedType = OmnifeedItemId.typeProfilePost;
        break;
      case 'thread':
        encodedType = OmnifeedItemId.typeThread;
        break;
      case 'tl_group_post':
        encodedType = OmnifeedItemId.typeGroupPost;
        break;
      case 'ubs_blog_entry':
        encodedType = OmnifeedItemId.typeBlogPost;
        break;
      case 'xfmg_media':
        encodedType = OmnifeedItemId.typeMedia;
        break;
      default:
        return 0;
    }

    if (nativeId <= 0 || encodedType <= 0) return 0;
    return OmnifeedItemId.encode(encodedType, nativeId);
  }

  factory OmnifeedItem.fromFeedJson(Map<String, dynamic> json) {
    return OmnifeedItem.fromJson(normalizeFeedItemJson(json));
  }

  OmnifeedItem withResolvedItemId() {
    final resolved = resolveItemId(
      contentType: contentType,
      rawItemId: itemId,
      contentId: contentId,
      profilePostId: contentType == 'profile_post' ? (contentId ?? 0) : 0,
    );
    if (resolved <= 0 || resolved == itemId) return this;
    return OmnifeedItem(
      itemId: resolved,
      contentType: contentType,
      contentId: contentId ?? OmnifeedItemId.decodeNativeId(resolved),
      contentTitle: contentTitle,
      messagePlainText: messagePlainText,
      messageParsed: messageParsed,
      itemDate: itemDate,
      activityDate: activityDate,
      commentCount: commentCount,
      reactionScore: reactionScore,
      visitorReactionId: visitorReactionId,
      isBookmarked: isBookmarked,
      isHighlighted: isHighlighted,
      canHighlight: canHighlight,
      highlightScope: highlightScope,
      shareCount: shareCount,
      isShare: isShare,
      sharedItem: sharedItem,
      author: author,
      categoryLabel: categoryLabel,
      blogLabel: blogLabel,
      blogId: blogId,
      blogCategoryId: blogCategoryId,
      forumId: forumId,
      albumId: albumId,
      albumLabel: albumLabel,
      mediaCategoryId: mediaCategoryId,
      mediaThumbnailUrl: mediaThumbnailUrl,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      mediaDurationSeconds: mediaDurationSeconds,
      viewUrl: viewUrl,
      groupId: groupId,
      tags: tags,
      attachments: attachments,
      linkPreviews: linkPreviews,
      isPaidContent: isPaidContent,
      canViewFull: canViewFull,
      previewCtaLabel: previewCtaLabel,
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
    String? categoryHeaderColor;
    if (json['Category'] is Map) {
      final cat = json['Category'] as Map;
      category = cat['title']?.toString();
      categoryHeaderColor = cat['header_color']?.toString();
    }
    if (category == null && content?['Category'] is Map) {
      final cat = content!['Category'] as Map;
      category = cat['title']?.toString();
      categoryHeaderColor ??= cat['header_color']?.toString();
    } else if (category == null && profile?['Category'] is Map) {
      category = (profile!['Category'] as Map)['title']?.toString();
    } else if (group?['Group'] is Map) {
      category = (group!['Group'] as Map)['name']?.toString();
    }

    String? blogTitle;
    int? blogId;
    int? blogCategoryId;
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
    for (final source in [
      json['BlogEntryItem'] is Map ? (json['BlogEntryItem'] as Map)['Category'] : null,
      content?['Category'],
      json['Category'],
    ]) {
      if (source is Map) {
        final id = source['category_id'] as int?;
        if (id != null && id > 0) {
          blogCategoryId = id;
          break;
        }
      }
    }
    int? forumId;
    if (content?['Category'] is Map) {
      forumId = (content!['Category'] as Map)['node_id'] as int?;
    }
    for (final source in [json['Forum'], content?['Forum']]) {
      if (source is Map) {
        forumId ??= source['node_id'] as int?;
        final title = source['title']?.toString().trim();
        if (title != null && title.isNotEmpty) {
          category ??= title;
        }
      }
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

    final mediaPayload = json['Media'] is Map
        ? Map<String, dynamic>.from(json['Media'] as Map)
        : null;

    String? albumTitle;
    int? albumId;
    int? mediaCategoryId;
    for (final source in [json['Category'], content?['Category']]) {
      if (source is Map) {
        final id = source['category_id'] as int?;
        if (id != null && id > 0) mediaCategoryId = id;
      }
    }
    for (final source in [
      json['Album'],
      json['album'],
      content?['Album'],
      content?['album'],
      mediaPayload?['Album'],
      mediaPayload?['album'],
    ]) {
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
    if (albumId == null && mediaPayload?['album_id'] is int) {
      final id = mediaPayload!['album_id'] as int;
      if (id > 0) albumId = id;
    }
    if (albumTitle == null || albumTitle.isEmpty) {
      final label = json['album_label']?.toString().trim() ??
          mediaPayload?['album_label']?.toString().trim();
      if (label != null && label.isNotEmpty) albumTitle = label;
    }
    if ((albumTitle == null || albumTitle.isEmpty) && albumId != null) {
      final container = json['container_name']?.toString().trim() ??
          mediaPayload?['container_name']?.toString().trim();
      if (container != null && container.isNotEmpty) {
        albumTitle = container;
      }
    }

    final contentTypeRaw = json['content_type']?.toString();
    final blogEntryItem = json['BlogEntryItem'] is Map<String, dynamic>
        ? json['BlogEntryItem'] as Map<String, dynamic>
        : null;

    String? blogCoverThumb;
    for (final source in [
      json['CoverImage'],
      blogEntryItem?['CoverImage'],
      content?['CoverImage'],
    ]) {
      if (source is Map) {
        final url = source['thumbnail_url']?.toString().trim() ??
            source['direct_url']?.toString().trim();
        if (url != null && url.isNotEmpty) {
          blogCoverThumb = url;
          break;
        }
      }
    }
    blogCoverThumb ??= json['hero_url']?.toString().trim();

    final isPaidContent = JsonParse.boolValue(
      json['is_paid_content'] ?? blogEntryItem?['is_paid_content'],
    );
    final canViewFull = json.containsKey('can_view_full') ||
            (blogEntryItem?.containsKey('can_view_full') ?? false)
        ? JsonParse.boolValue(
            json['can_view_full'] ?? blogEntryItem?['can_view_full'],
          )
        : true;
    final previewCtaLabel = json['preview_cta_label']?.toString() ??
        blogEntryItem?['preview_cta_label']?.toString();

    final mediaThumb = blogCoverThumb ??
        json['thumbnail_url']?.toString() ??
        content?['thumbnail_url']?.toString() ??
        mediaPayload?['thumbnail_url']?.toString();
    final mediaDirect = json['media_url']?.toString() ??
        content?['media_url']?.toString() ??
        mediaPayload?['media_url']?.toString();
    final mediaKind = json['media_type']?.toString() ??
        content?['media_type']?.toString() ??
        mediaPayload?['media_type']?.toString();
    final mediaDuration = _parseMediaDuration(json, mediaPayload);

    final resolvedItemId = resolveItemId(
      contentType: contentTypeRaw,
      rawItemId: JsonParse.intValue(json['item_id']),
      contentId: JsonParse.intOrNull(json['content_id']),
      profilePostId: JsonParse.intValue(
        json['profile_post_id'] ?? profile?['profile_post_id'],
      ),
    );

    return OmnifeedItem(
      itemId: resolvedItemId,
      contentType: contentTypeRaw ?? (profile != null ? 'profile_post' : null),
      contentId: JsonParse.intOrNull(json['content_id']) ??
          (resolvedItemId > 0
              ? OmnifeedItemId.decodeNativeId(resolvedItemId)
              : null),
      contentTitle: json['ContentTitle']?.toString(),
      messagePlainText: json['message_plain_text']?.toString(),
      messageParsed: json['message_parsed']?.toString(),
      itemDate: JsonParse.intOrNull(json['item_date']),
      activityDate: JsonParse.intOrNull(json['activity_date']) ??
          JsonParse.intOrNull(json['sort_date']),
      commentCount: JsonParse.intValue(json['comment_count']),
      reactionScore: JsonParse.intValue(json['reaction_score']),
      visitorReactionId: JsonParse.intOrNull(json['visitor_reaction_id']),
      isBookmarked: JsonParse.boolValue(json['is_bookmarked']),
      isHighlighted: JsonParse.boolValue(json['is_highlighted']) ||
          JsonParse.boolValue(json['isHighlighted']),
      canHighlight: JsonParse.boolValue(json['can_highlight']) ||
          JsonParse.boolValue(json['canHighlight']),
      highlightScope: json['highlight_scope']?.toString(),
      shareCount: JsonParse.intValue(json['share_count']),
      isShare: json['is_share'] == true,
      sharedItem: () {
        final raw = json['shared_item'];
        if (raw is Map) {
          return OmnifeedItem.fromFeedJson(Map<String, dynamic>.from(raw));
        }
        return null;
      }(),
      author: _authorFromFeedJson(json),
      categoryLabel: category,
      categoryHeaderColor: categoryHeaderColor,
      blogLabel: blogTitle,
      blogId: blogId,
      blogCategoryId: blogCategoryId,
      forumId: forumId,
      albumId: albumId,
      albumLabel: albumTitle,
      mediaCategoryId: mediaCategoryId,
      mediaThumbnailUrl: mediaThumb,
      mediaUrl: mediaDirect,
      mediaType: mediaKind,
      mediaDurationSeconds: mediaDuration,
      viewUrl: json['view_url']?.toString(),
      groupId: groupId,
      tags: JsonParse.parseFeedTags(json['tags']),
      attachments: FeedAttachment.parseList(json['Attachments']),
      linkPreviews: FeedLinkPreviewData.listFromJson(json['link_previews']),
      isPaidContent: isPaidContent,
      canViewFull: canViewFull,
      previewCtaLabel: previewCtaLabel,
    );
  }

  static OmnifeedAuthor? _authorFromFeedJson(Map<String, dynamic> json) {
    final userMap = _userMapFromApiJson(json);
    if (userMap != null) {
      return OmnifeedAuthor.fromJson(userMap);
    }
    final userId = JsonParse.intOrNull(json['user_id']);
    if (userId == null || userId <= 0) return null;
    return OmnifeedAuthor(
      userId: userId,
      username: json['username']?.toString() ?? '',
    );
  }

  static int? _parseMediaDuration(
    Map<String, dynamic> json,
    Map<String, dynamic>? mediaPayload,
  ) {
    for (final source in [json, if (mediaPayload != null) mediaPayload]) {
      for (final key in [
        'media_duration',
        'duration',
        'video_duration',
        'media_duration_seconds',
      ]) {
        final value = source[key];
        if (value is int && value > 0) return value;
        if (value is num && value > 0) return value.round();
      }
    }
    return null;
  }


  OmnifeedItem copyWith({
    int? reactionScore,
    int? visitorReactionId,
    bool? isBookmarked,
    bool? isHighlighted,
    bool? canHighlight,
    String? highlightScope,
    int? shareCount,
    int? activityDate,
  }) {
    return OmnifeedItem(
      itemId: itemId,
      contentType: contentType,
      contentId: contentId,
      contentTitle: contentTitle,
      messagePlainText: messagePlainText,
      messageParsed: messageParsed,
      itemDate: itemDate,
      activityDate: activityDate ?? this.activityDate,
      commentCount: commentCount,
      reactionScore: reactionScore ?? this.reactionScore,
      visitorReactionId: visitorReactionId ?? this.visitorReactionId,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      canHighlight: canHighlight ?? this.canHighlight,
      highlightScope: highlightScope ?? this.highlightScope,
      shareCount: shareCount ?? this.shareCount,
      isShare: isShare,
      sharedItem: sharedItem,
      author: author,
      categoryLabel: categoryLabel,
      blogLabel: blogLabel,
      blogId: blogId,
      blogCategoryId: blogCategoryId,
      forumId: forumId,
      albumId: albumId,
      albumLabel: albumLabel,
      mediaCategoryId: mediaCategoryId,
      mediaThumbnailUrl: mediaThumbnailUrl,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      mediaDurationSeconds: mediaDurationSeconds,
      viewUrl: viewUrl,
      groupId: groupId,
      tags: tags,
      attachments: attachments,
      linkPreviews: linkPreviews,
    );
  }

  OmnifeedItem mergedWith(OmnifeedItem other) {
    return OmnifeedItem(
      itemId: itemId,
      contentType: contentType ?? other.contentType,
      contentId: contentId ?? other.contentId,
      contentTitle: _pickText(contentTitle, other.contentTitle),
      messagePlainText: _pickText(messagePlainText, other.messagePlainText),
      messageParsed: _pickText(messageParsed, other.messageParsed),
      itemDate: itemDate ?? other.itemDate,
      commentCount: commentCount > 0 ? commentCount : other.commentCount,
      reactionScore: reactionScore > 0 ? reactionScore : other.reactionScore,
      visitorReactionId: visitorReactionId ?? other.visitorReactionId,
      isBookmarked: isBookmarked || other.isBookmarked,
      isHighlighted: isHighlighted || other.isHighlighted,
      canHighlight: canHighlight || other.canHighlight,
      highlightScope: highlightScope ?? other.highlightScope,
      shareCount: shareCount > 0 ? shareCount : other.shareCount,
      isShare: isShare || other.isShare,
      sharedItem: sharedItem ?? other.sharedItem,
      author: _mergeAuthors(author, other.author),
      categoryLabel: _pickText(categoryLabel, other.categoryLabel),
      blogLabel: _pickText(blogLabel, other.blogLabel),
      blogId: (blogId ?? 0) > 0 ? blogId : other.blogId,
      forumId: (forumId ?? 0) > 0 ? forumId : other.forumId,
      albumId: (albumId ?? 0) > 0 ? albumId : other.albumId,
      albumLabel: _pickText(albumLabel, other.albumLabel),
      mediaCategoryId:
          (mediaCategoryId ?? 0) > 0 ? mediaCategoryId : other.mediaCategoryId,
      mediaThumbnailUrl: _pickText(mediaThumbnailUrl, other.mediaThumbnailUrl),
      mediaUrl: _pickText(mediaUrl, other.mediaUrl),
      mediaType: _pickText(mediaType, other.mediaType),
      mediaDurationSeconds: (mediaDurationSeconds ?? 0) > 0
          ? mediaDurationSeconds
          : other.mediaDurationSeconds,
      viewUrl: _pickText(viewUrl, other.viewUrl),
      groupId: (groupId ?? 0) > 0 ? groupId : other.groupId,
      tags: tags.isNotEmpty ? tags : other.tags,
      attachments: attachments.isNotEmpty ? attachments : other.attachments,
      linkPreviews:
          linkPreviews.isNotEmpty ? linkPreviews : other.linkPreviews,
    );
  }

  OmnifeedItem enrichedFromMedia(MediaItem? media) {
    if (media == null || contentType != 'xfmg_media') return this;
    final albumTitle = media.album?.title.trim();
    final categoryTitle = media.category?.title.trim();
    final mediaAuthor = media.author;
    return OmnifeedItem(
      itemId: itemId,
      contentType: contentType,
      contentId: contentId ?? media.mediaId,
      contentTitle: _pickText(contentTitle, media.title),
      messagePlainText: _pickText(messagePlainText, media.description),
      messageParsed: _pickText(messageParsed, media.description),
      itemDate: itemDate ?? media.mediaDate,
      commentCount: commentCount > 0 ? commentCount : media.commentCount,
      reactionScore: reactionScore > 0 ? reactionScore : media.reactionScore,
      visitorReactionId: visitorReactionId ?? media.visitorReactionId,
      isBookmarked: isBookmarked,
      isHighlighted: isHighlighted,
      canHighlight: canHighlight,
      highlightScope: highlightScope,
      shareCount: shareCount,
      isShare: isShare,
      sharedItem: sharedItem,
      author: mediaAuthor == null
          ? author
          : OmnifeedAuthor(
              userId: author?.userId ?? mediaAuthor.userId,
              username: _pickText(author?.username, mediaAuthor.username) ?? '',
              avatarUrl: _pickText(author?.avatarUrl, mediaAuthor.avatarUrl),
              displayName:
                  _pickText(author?.displayName, mediaAuthor.displayName),
              signatureHtml: _pickText(
                author?.signatureHtml,
                mediaAuthor.signatureHtml,
              ),
              signaturePlain: _pickText(
                author?.signaturePlain,
                mediaAuthor.signaturePlain,
              ),
              contentShowSignature: (author?.hasVisibleSignature ?? false)
                  ? author!.contentShowSignature
                  : mediaAuthor.contentShowSignature,
            ),
      categoryLabel: _pickText(categoryLabel, categoryTitle),
      blogLabel: blogLabel,
      blogId: blogId,
      forumId: forumId,
      albumId: (albumId ?? 0) > 0 ? albumId : media.album?.albumId,
      albumLabel: _pickText(albumLabel, albumTitle),
      mediaCategoryId:
          (mediaCategoryId ?? 0) > 0 ? mediaCategoryId : media.category?.categoryId,
      mediaThumbnailUrl:
          _pickText(mediaThumbnailUrl, media.thumbnailUrl ?? media.heroImageUrl),
      mediaUrl: _pickText(mediaUrl, media.mediaUrl),
      mediaType: _pickText(mediaType, media.mediaType),
      mediaDurationSeconds: (mediaDurationSeconds ?? 0) > 0
          ? mediaDurationSeconds
          : media.durationSeconds,
      viewUrl: _pickText(viewUrl, media.viewUrl),
      groupId: groupId,
      tags: tags.isNotEmpty ? tags : media.tags,
      attachments: attachments,
      linkPreviews: linkPreviews,
    );
  }

  static String? _pickText(String? primary, String? secondary) {
    final first = primary?.trim();
    if (first != null && first.isNotEmpty) return first;
    final second = secondary?.trim();
    if (second != null && second.isNotEmpty) return second;
    return primary ?? secondary;
  }

  static OmnifeedAuthor? _mergeAuthors(
    OmnifeedAuthor? a,
    OmnifeedAuthor? b,
  ) {
    if (a == null) return b;
    if (b == null) return a;
    return OmnifeedAuthor(
      userId: a.userId > 0 ? a.userId : b.userId,
      username: _pickText(a.username, b.username) ?? '',
      avatarUrl: _pickText(a.avatarUrl, b.avatarUrl),
      displayName: _pickText(a.displayName, b.displayName),
      signatureHtml: _pickText(a.signatureHtml, b.signatureHtml),
      signaturePlain: _pickText(a.signaturePlain, b.signaturePlain),
      contentShowSignature: a.hasVisibleSignature
          ? a.contentShowSignature
          : b.contentShowSignature,
    );
  }
}

class OmnifeedAuthor {
  OmnifeedAuthor({
    required this.userId,
    required this.username,
    this.avatarUrl,
    this.displayName,
    this.signatureHtml,
    this.signaturePlain,
    this.contentShowSignature = true,
  });

  final int userId;
  final String username;
  final String? avatarUrl;
  final String? displayName;
  final String? signatureHtml;
  final String? signaturePlain;
  final bool contentShowSignature;

  String get label => displayName?.trim().isNotEmpty == true
      ? displayName!
      : username;

  bool get hasVisibleSignature {
    if (!contentShowSignature) return false;
    final html = signatureHtml?.trim() ?? '';
    final plain = signaturePlain?.trim() ?? '';
    return html.isNotEmpty || plain.isNotEmpty;
  }

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
    final sig = AuthorSignatureFields.fromJson(json);
    return OmnifeedAuthor(
      userId: JsonParse.intValue(json['user_id']),
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
      displayName: fullName,
      signatureHtml: sig.signatureHtml,
      signaturePlain: sig.signaturePlain,
      contentShowSignature: sig.contentShowSignature,
    );
  }
}
