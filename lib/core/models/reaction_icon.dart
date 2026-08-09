import 'package:kairete/config/app_config.dart';

class ReactionIcon {
  ReactionIcon({
    required this.reactionId,
    required this.title,
    required this.imageUrl,
    this.emoji = '',
    this.emojiShortname = '',
    this.active = true,
  });

  final int reactionId;
  final String title;
  final String imageUrl;
  final String emoji;
  final String emojiShortname;
  final bool active;

  bool get hasNetworkImage =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  factory ReactionIcon.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['image_url']?.toString() ?? '';
    final emoji = json['emoji']?.toString() ?? '';
    final shortname = json['emoji_shortname']?.toString() ?? '';
    var imageUrl = _resolveUrl(rawUrl);

    // Se l'API non ha ancora risolto Twemoji, usa il CDN ufficiale XF.
    if (!imageUrl.startsWith('http') && shortname.isNotEmpty) {
      imageUrl = _twemojiUrlForShortname(shortname) ?? imageUrl;
    }
    if (!imageUrl.startsWith('http')) {
      imageUrl = _twemojiUrlForReactionId(json['reaction_id'] as int? ?? 0) ??
          imageUrl;
    }

    return ReactionIcon(
      reactionId: json['reaction_id'] as int? ?? 0,
      title: json['title']?.toString() ?? '',
      imageUrl: imageUrl,
      emoji: emoji,
      emojiShortname: shortname,
      active: json['active'] as bool? ?? true,
    );
  }

  static String _resolveUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http://') ||
        raw.startsWith('https://') ||
        raw.startsWith('data:')) {
      return raw;
    }
    final base = AppConfig.apiBaseUrl;
    if (raw.startsWith('/')) return '$base${raw.substring(1)}';
    return '$base$raw';
  }

  /// Codepoint Twemoji 14 (come XenForo 2.3 default reactions).
  static String? _twemojiUrlForShortname(String shortname) {
    const map = {
      ':thumbsup:': '1f44d',
      ':+1:': '1f44d',
      ':heart_eyes:': '1f60d',
      ':rofl:': '1f923',
      ':astonished:': '1f632',
      ':slight_frown:': '1f641',
      ':rage:': '1f621',
      ':thumbsdown:': '1f44e',
      ':-1:': '1f44e',
    };
    final code = map[shortname.toLowerCase()];
    if (code == null) return null;
    return 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/$code.png';
  }

  static String? _twemojiUrlForReactionId(int id) {
    const map = {
      1: '1f44d',
      2: '1f60d',
      3: '1f923',
      4: '1f632',
      5: '1f641',
      6: '1f621',
    };
    final code = map[id];
    if (code == null) return null;
    return 'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/$code.png';
  }
}
