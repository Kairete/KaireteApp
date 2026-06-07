import 'package:kairete/config/app_config.dart';

class ReactionIcon {
  ReactionIcon({
    required this.reactionId,
    required this.title,
    required this.imageUrl,
    this.active = true,
  });

  final int reactionId;
  final String title;
  final String imageUrl;
  final bool active;

  factory ReactionIcon.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url']?.toString() ?? '';
    return ReactionIcon(
      reactionId: json['reaction_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      imageUrl: _resolveUrl(rawUrl),
      active: json['active'] as bool? ?? true,
    );
  }

  static String _resolveUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final base = AppConfig.apiBaseUrl;
    if (raw.startsWith('/')) return '$base${raw.substring(1)}';
    return '$base$raw';
  }
}
