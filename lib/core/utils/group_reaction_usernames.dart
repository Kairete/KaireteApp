import 'dart:convert';

/// Reads only real usernames supplied by the server. XenForo's reaction_users
/// may be an array or a JSON-serialized array depending on the addon serializer.
class GroupReactionUsernames {
  GroupReactionUsernames._();

  static List<String> fromPost(Map<String, dynamic> payload) {
    final nested = payload['GroupPost'];
    final sources = <Map<String, dynamic>>[
      payload,
      if (nested is Map) Map<String, dynamic>.from(nested),
    ];
    for (final source in sources) {
      for (final name in [
        'reaction_users', 'ReactionUsers', 'reaction_user_list',
        'reacted_users', 'reaction_summary_users',
      ]) {
        final parsed = _decode(source[name]);
        final usernames = <String>[];
        final seen = <String>{};
        if (parsed is List) {
          for (final entry in parsed) {
            final raw = entry is Map
                ? (entry['username'] ?? entry['display_name'] ??
                    (entry['User'] is Map ? entry['User']['username'] : null))
                : entry is String ? entry : null;
            final username = raw?.toString().trim();
            if (username != null && username.isNotEmpty &&
                seen.add(username.toLowerCase())) {
              usernames.add(username);
            }
          }
        }
        if (usernames.isNotEmpty) return usernames;
      }
    }
    return const [];
  }

  static dynamic _decode(dynamic value) {
    if (value is String && (value.trim().startsWith('[') ||
        value.trim().startsWith('{'))) {
      try {
        return jsonDecode(value);
      } on FormatException {
        return null;
      }
    }
    if (value is Map) {
      final values = value.values.toList();
      return values;
    }
    return value;
  }
}
