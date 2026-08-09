class MediaAlbumProfile {
  MediaAlbumProfile({
    required this.albumId,
    required this.title,
    this.categoryId = 0,
    this.description = '',
    this.coverUrl,
    this.isWatched = false,
    this.canWatch = true,
    this.ownerUsername,
    this.ownerAvatarUrl,
  });

  final int albumId;
  final String title;
  final int categoryId;
  final String description;
  final String? coverUrl;
  final bool isWatched;
  final bool canWatch;
  final String? ownerUsername;
  final String? ownerAvatarUrl;

  bool get hasCover => coverUrl != null && coverUrl!.trim().isNotEmpty;

  MediaAlbumProfile copyWith({String? coverUrl}) {
    return MediaAlbumProfile(
      albumId: albumId,
      title: title,
      categoryId: categoryId,
      description: description,
      coverUrl: coverUrl ?? this.coverUrl,
      isWatched: isWatched,
      canWatch: canWatch,
      ownerUsername: ownerUsername,
      ownerAvatarUrl: ownerAvatarUrl,
    );
  }

  factory MediaAlbumProfile.fromJson(Map<String, dynamic> json) {
    String? cover;
    final thumb = json['thumbnail_url']?.toString();
    final custom = json['custom_thumbnail_url']?.toString();
    final icon = json['icon_url']?.toString();
    if (thumb != null && thumb.isNotEmpty) {
      cover = thumb;
    } else if (custom != null && custom.isNotEmpty) {
      cover = custom;
    } else if (icon != null && icon.isNotEmpty) {
      cover = icon;
    }
    final lastMedia = json['LastMedia'];
    if ((cover == null || cover.isEmpty) && lastMedia is Map) {
      final lastThumb = lastMedia['thumbnail_url']?.toString();
      if (lastThumb != null && lastThumb.isNotEmpty) {
        cover = lastThumb;
      }
    }

    String? ownerName;
    String? ownerAvatar;
    final user = json['User'];
    if (user is Map) {
      ownerName = user['username']?.toString();
      final urls = user['avatar_urls'];
      if (urls is Map) {
        ownerAvatar = urls['m']?.toString() ?? urls['s']?.toString();
      }
    }

    var categoryId = json['category_id'] as int? ?? 0;
    final category = json['Category'];
    if (categoryId <= 0 && category is Map) {
      categoryId = category['category_id'] as int? ?? 0;
    }

    return MediaAlbumProfile(
      albumId: json['album_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      categoryId: categoryId,
      description: json['description']?.toString() ?? '',
      coverUrl: cover,
      isWatched: json['is_watching'] as bool? ??
          json['is_watched'] as bool? ??
          false,
      canWatch: json['can_watch'] as bool? ?? true,
      ownerUsername: ownerName ?? json['username']?.toString(),
      ownerAvatarUrl: ownerAvatar,
    );
  }
}
