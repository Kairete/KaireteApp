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
        avatar = urls['m']?.toString() ??
            urls['l']?.toString() ??
            urls['s']?.toString();
      }
    }

    final blogId = json['blog_id'] as int? ?? 0;
    final coverDate = json['cover_date'] as int? ?? 0;
    var cover = ApiUrl.resolve(json['cover_url']?.toString());
    // API live a volte omette cover_url anche se il file esiste.
    if (cover.isEmpty && blogId > 0) {
      cover = ApiUrl.resolve('data/kairete_blog_covers/$blogId.jpg');
      if (coverDate > 0) {
        cover = '$cover?t=$coverDate';
      }
    }

    return BlogProfile(
      blogId: blogId,
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverUrl: cover.isEmpty ? null : cover,
      isWatched: json['is_watched'] == true,
      canWatch: json['can_watch'] != false,
      ownerUsername: username,
      ownerAvatarUrl: avatar != null ? ApiUrl.resolve(avatar) : null,
    );
  }
}
