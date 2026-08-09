import 'package:kairete/core/utils/media_playback.dart';
import 'package:kairete/features/feed/models/author_signature_fields.dart';

class MediaAuthor {
  MediaAuthor({
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

  String get label =>
      displayName?.trim().isNotEmpty == true ? displayName! : username;

  bool get hasVisibleSignature {
    if (!contentShowSignature) return false;
    final html = signatureHtml?.trim() ?? '';
    final plain = signaturePlain?.trim() ?? '';
    return html.isNotEmpty || plain.isNotEmpty;
  }

  factory MediaAuthor.fromJson(Map<String, dynamic> json) {
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
    return MediaAuthor(
      userId: json['user_id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      avatarUrl: avatar,
      displayName: fullName,
      signatureHtml: sig.signatureHtml,
      signaturePlain: sig.signaturePlain,
      contentShowSignature: sig.contentShowSignature,
    );
  }
}

class MediaAlbumRef {
  MediaAlbumRef({required this.albumId, required this.title});

  final int albumId;
  final String title;

  factory MediaAlbumRef.fromJson(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim() ??
        json['album_title']?.toString().trim() ??
        json['name']?.toString().trim() ??
        '';
    return MediaAlbumRef(
      albumId: json['album_id'] as int? ?? 0,
      title: title,
    );
  }
}

class MediaCategoryRef {
  MediaCategoryRef({required this.categoryId, required this.title});

  final int categoryId;
  final String title;

  factory MediaCategoryRef.fromJson(Map<String, dynamic> json) {
    return MediaCategoryRef(
      categoryId: json['category_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
    );
  }
}

class MediaItem {
  MediaItem({
    required this.mediaId,
    this.title,
    this.description,
    this.mediaDate,
    this.mediaType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaEmbedUrl,
    this.commentCount = 0,
    this.reactionScore = 0,
    this.canReact = true,
    this.visitorReactionId,
    this.author,
    this.album,
    this.category,
    this.tags = const [],
    this.viewUrl,
    this.durationSeconds,
  });

  final int mediaId;
  final String? title;
  final String? description;
  final int? mediaDate;
  final String? mediaType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? mediaEmbedUrl;
  final int commentCount;
  final int reactionScore;
  final bool canReact;
  final int? visitorReactionId;
  final MediaAuthor? author;
  final MediaAlbumRef? album;
  final MediaCategoryRef? category;
  final List<String> tags;
  final String? viewUrl;
  final int? durationSeconds;

  bool get isVideo =>
      mediaType == 'video' ||
      mediaType == 'video_upload' ||
      (mediaUrl?.contains('.mp4') ?? false) ||
      (mediaUrl?.contains('.webm') ?? false) ||
      (mediaUrl?.contains('.mov') ?? false);

  bool get isAudio =>
      mediaType == 'audio' ||
      mediaType == 'audio_upload' ||
      (mediaUrl?.contains('.mp3') ?? false) ||
      (mediaUrl?.contains('.m4a') ?? false) ||
      (mediaUrl?.contains('.wav') ?? false) ||
      (mediaUrl?.contains('.ogg') ?? false);

  bool get isPlayable => isVideo || isAudio;

  String get displayTitle => title?.trim().isNotEmpty == true ? title!.trim() : 'Media';

  /// Titolo album per l'header feed (`nickname > album`).
  String? get albumHeaderLabel {
    final label = album?.title.trim();
    if (label != null && label.isNotEmpty) return label;
    return null;
  }

  MediaItem withAlbumTitle(String title) {
    final albumId = album?.albumId ?? 0;
    if (albumId <= 0) return this;
    return MediaItem(
      mediaId: mediaId,
      title: title,
      description: description,
      mediaDate: mediaDate,
      mediaType: mediaType,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      mediaEmbedUrl: mediaEmbedUrl,
      commentCount: commentCount,
      reactionScore: reactionScore,
      canReact: canReact,
      visitorReactionId: visitorReactionId,
      author: author,
      album: MediaAlbumRef(albumId: albumId, title: title),
      category: category,
      tags: tags,
      viewUrl: viewUrl,
      durationSeconds: durationSeconds,
    );
  }

  String get previewBody {
    final plain = description?.trim();
    if (plain != null && plain.isNotEmpty) return plain;
    return '';
  }

  bool get previewHasMore {
    final body = previewBody;
    if (body.isEmpty) return false;
    return body.length >= 280;
  }

  String get listPreviewBody {
    final body = previewBody;
    if (body.isEmpty) return '';
    if (!previewHasMore) return body;
    if (body.length <= 277) return '$body…';
    return '${body.substring(0, 277).trimRight()}…';
  }

  String? get heroImageUrl {
    final thumb = thumbnailUrl?.trim();
    if (thumb != null && thumb.isNotEmpty) {
      return MediaPlayback.resolveAbsoluteUrl(thumb);
    }
    if (isPlayable && mediaId > 0) {
      final apiThumb =
          MediaPlayback.thumbnailEndpointUrl(mediaId);
      if (apiThumb.isNotEmpty) return apiThumb;
    }
    final direct = mediaUrl?.trim();
    if (direct != null && direct.isNotEmpty && !isPlayable) {
      return MediaPlayback.resolveAbsoluteUrl(direct);
    }
    return null;
  }

  String? get openMediaUrl {
    final type = mediaType?.toLowerCase() ?? '';
    final isEmbedType = type == 'embed';

    final direct = mediaUrl?.trim();
    if (direct != null && direct.isNotEmpty && !isEmbedType) {
      return MediaPlayback.resolveAbsoluteUrl(direct);
    }

    if (mediaId > 0 && isPlayable && !isEmbedType) {
      return MediaPlayback.dataEndpointUrl(mediaId);
    }

    final embed = mediaEmbedUrl?.trim();
    if (embed != null && embed.isNotEmpty) {
      return MediaPlayback.resolveAbsoluteUrl(embed);
    }

    if (direct != null && direct.isNotEmpty) {
      return MediaPlayback.resolveAbsoluteUrl(direct);
    }
    return null;
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    MediaAlbumRef? album;
    final albumRaw = json['Album'] ?? json['album'];
    if (albumRaw is Map) {
      album = MediaAlbumRef.fromJson(Map<String, dynamic>.from(albumRaw));
    } else if (json['album_id'] is int && json['album_id'] as int > 0) {
      final albumTitle = json['album_label']?.toString().trim() ??
          json['container_name']?.toString().trim() ??
          '';
      album = MediaAlbumRef(
        albumId: json['album_id'] as int,
        title: albumTitle,
      );
    } else if (json['container_type']?.toString() == 'album' &&
        json['container_id'] is int &&
        (json['container_id'] as int) > 0) {
      album = MediaAlbumRef(
        albumId: json['container_id'] as int,
        title: json['container_name']?.toString().trim() ?? '',
      );
    }

    MediaCategoryRef? category;
    final catRaw = json['Category'];
    if (catRaw is Map<String, dynamic>) {
      category = MediaCategoryRef.fromJson(catRaw);
    } else if (json['category_id'] is int && json['category_id'] as int > 0) {
      category = MediaCategoryRef(
        categoryId: json['category_id'] as int,
        title: json['category_title']?.toString().trim() ?? '',
      );
    }

    MediaAuthor? author;
    if (json['User'] is Map<String, dynamic>) {
      author = MediaAuthor.fromJson(json['User'] as Map<String, dynamic>);
    } else if (json['user_id'] is int) {
      author = MediaAuthor(
        userId: json['user_id'] as int,
        username: json['username']?.toString() ?? '',
      );
    }

    return MediaItem(
      mediaId: json['media_id'] as int? ?? json['content_id'] as int? ?? 0,
      title: json['title']?.toString() ?? json['ContentTitle']?.toString(),
      description: json['description']?.toString(),
      mediaDate: json['media_date'] as int?,
      mediaType: json['media_type']?.toString(),
      mediaUrl: json['media_url']?.toString(),
      thumbnailUrl: json['thumbnail_url']?.toString(),
      mediaEmbedUrl: json['media_embed_url']?.toString(),
      commentCount: json['comment_count'] as int? ?? 0,
      reactionScore: json['reaction_score'] as int? ?? 0,
      canReact: json['can_react'] as bool? ?? true,
      visitorReactionId: json['visitor_reaction_id'] as int?,
      author: author,
      album: album,
      category: category,
      tags: _parseTags(json['tags']),
      viewUrl: json['view_url']?.toString(),
      durationSeconds: _parseDurationSeconds(json),
    );
  }

  static int? _parseDurationSeconds(Map<String, dynamic> json) {
    for (final key in [
      'media_duration',
      'duration',
      'video_duration',
      'media_duration_seconds',
    ]) {
      final value = json[key];
      if (value is int && value > 0) return value;
      if (value is num && value > 0) return value.round();
    }
    return null;
  }

  static List<String> _parseTags(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((tag) {
          if (tag is String) return tag.trim();
          if (tag is Map) return tag['tag']?.toString().trim() ?? '';
          return '';
        })
        .where((t) => t.isNotEmpty)
        .toList();
  }
}

class MediaAlbum {
  MediaAlbum({
    required this.albumId,
    required this.title,
    this.categoryId = 0,
  });

  final int albumId;
  final String title;
  final int categoryId;

  factory MediaAlbum.fromJson(Map<String, dynamic> json) {
    var categoryId = json['category_id'] as int? ?? 0;
    for (final key in ['Category', 'category']) {
      final nested = json[key];
      if (categoryId <= 0 && nested is Map) {
        categoryId = nested['category_id'] as int? ?? 0;
      }
    }
    return MediaAlbum(
      albumId: json['album_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      categoryId: categoryId,
    );
  }
}

class MediaCategory {
  MediaCategory({required this.categoryId, required this.title});

  final int categoryId;
  final String title;

  factory MediaCategory.fromJson(Map<String, dynamic> json) {
    return MediaCategory(
      categoryId: json['category_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
    );
  }
}
