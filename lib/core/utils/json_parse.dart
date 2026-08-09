/// Parsing JSON XenForo/API tollerante (int anche come stringa o double).
class JsonParse {
  JsonParse._();

  static int intValue(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// Bool tollerante: true/false, 1/0, "1"/"0", "true"/"false".
  static bool boolValue(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final s = value.trim().toLowerCase();
      if (s == '1' || s == 'true' || s == 'yes') return true;
      if (s == '0' || s == 'false' || s == 'no' || s.isEmpty) return false;
    }
    return fallback;
  }

  static List<String> parseFeedTags(dynamic raw) {
    if (raw == null) return const [];
    if (raw is String) {
      return raw
          .split(',')
          .map((tag) => tag.trim().replaceFirst(RegExp(r'^#'), ''))
          .where((tag) => tag.isNotEmpty)
          .toList();
    }
    if (raw is! List) return const [];
    return raw
        .map((tag) {
          if (tag is String) {
            return tag.trim().replaceFirst(RegExp(r'^#'), '');
          }
          if (tag is Map) {
            return tag['tag']?.toString().trim().replaceFirst(RegExp(r'^#'), '') ??
                tag['label']?.toString().trim().replaceFirst(RegExp(r'^#'), '') ??
                '';
          }
          return '';
        })
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
