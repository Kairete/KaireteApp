import 'package:kairete/core/utils/api_url.dart';

class BlogProfile {
  const BlogProfile({
    required this.blogId,
    required this.title,
    this.slug = '',
    this.description = '',
    this.coverUrl,
    this.isWatched = false,
    this.canWatch = true,
    this.ownerUsername,
    this.ownerAvatarUrl,
  });

  final int blogId;
  final String title;
  final String slug;
  final String description;
  final String? coverUrl;
  final bool isWatched;
  final bool canWatch;
  final String? ownerUsername;
  final String? ownerAvatarUrl;

  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;

  factory BlogProfile.fromJson(Map<String, dynamic> json) {
    String? avatar;
    String? username;
    final user = json['User'];
    if (user is Map<String, dynamic>) {
      username = user['username']?.toString();
      final urls = user['avatar_urls'];
      if (urls is Map) {
        avatar = urls['m']?.toString() ?? urls['s']?.toString();
      }
    }

    return BlogProfile(
      blogId: json['blog_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverUrl: ApiUrl.resolve(json['cover_url']?.toString()),
      isWatched: json['is_watched'] == true,
      canWatch: json['can_watch'] != false,
      ownerUsername: username,
      ownerAvatarUrl: avatar != null ? ApiUrl.resolve(avatar) : null,
    );
  }
}
