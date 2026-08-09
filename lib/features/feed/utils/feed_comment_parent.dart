/// Utility per parent id e inferenza da quote BBCode (forum/media/gruppi).
class FeedCommentParent {
  FeedCommentParent._();

  static final _quotePostPattern = RegExp(
    r'\[QUOTE[^\]]*post:\s*(\d+)',
    caseSensitive: false,
  );

  static final _quoteCommentPattern = RegExp(
    r'\[QUOTE[^\]]*(?:comment|media_comment|profile_post_comment|id):\s*(\d+)',
    caseSensitive: false,
  );

  static final _htmlQuoteCommentPattern = RegExp(
    r'data-content="(?:comment|media_comment|profile_post_comment|xfmg_media_comment)-(\d+)"|data-quote-id="(\d+)"',
    caseSensitive: false,
  );

  static int readParentId(Map<String, dynamic> json) {
    for (final key in const [
      'parent_comment_id',
      'parent_profile_post_comment_id',
      'parent_media_comment_id',
      'parent_post_id',
      'reply_post_id',
      'reply_to_post_id',
    ]) {
      final value = json[key];
      if (value is int && value > 0) return value;
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return 0;
  }

  static int readDepth(Map<String, dynamic> json) {
    final value = json['depth'];
    if (value is int && value >= 0) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static int inferQuotedId(
    String? message, {
    required Set<int> validIds,
    bool posts = false,
  }) {
    final text = message?.trim();
    if (text == null || text.isEmpty || validIds.isEmpty) return 0;

    if (posts) {
      final match = _quotePostPattern.firstMatch(text);
      if (match != null) {
        final id = int.tryParse(match.group(1) ?? '') ?? 0;
        if (id > 0 && validIds.contains(id)) return id;
      }
      return 0;
    }

    for (final pattern in [_quoteCommentPattern, _htmlQuoteCommentPattern]) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;
      final id = int.tryParse(match.group(1) ?? match.group(2) ?? '') ?? 0;
      if (id > 0 && validIds.contains(id)) return id;
    }
    return 0;
  }

  /// Ricostruisce parent mancanti da depth (lista già appiattita DFS).
  static List<int> inferParentsFromDepth({
    required List<int> ids,
    required List<int> parentIds,
    required List<int> depths,
    int maxDepth = 8,
  }) {
    if (ids.isEmpty) return parentIds;
    if (parentIds.length != ids.length || depths.length != ids.length) {
      return parentIds;
    }
    if (!depths.any((depth) => depth > 0)) return parentIds;

    final lastIdAtDepth = <int>[];
    final out = List<int>.from(parentIds);

    for (var i = 0; i < ids.length; i++) {
      final depth = depths[i].clamp(0, maxDepth);
      if (out[i] <= 0 && depth > 0 && depth - 1 < lastIdAtDepth.length) {
        final inferred = lastIdAtDepth[depth - 1];
        if (inferred > 0 && inferred != ids[i]) {
          out[i] = inferred;
        }
      }

      if (lastIdAtDepth.length > depth) {
        lastIdAtDepth.length = depth;
      }
      while (lastIdAtDepth.length <= depth) {
        lastIdAtDepth.add(0);
      }
      lastIdAtDepth[depth] = ids[i];
    }

    return out;
  }

  /// Completa parent mancanti usando quote nel messaggio.
  static List<int> enrichParentIds({
    required List<int> ids,
    required List<int> parentIds,
    required List<String?> messages,
    bool quotePosts = false,
  }) {
    if (ids.isEmpty) return parentIds;
    if (parentIds.length != ids.length || messages.length != ids.length) {
      return parentIds;
    }

    final validIds = ids.where((id) => id > 0).toSet();
    final out = List<int>.from(parentIds);

    for (var i = 0; i < ids.length; i++) {
      if (out[i] > 0) continue;
      final inferred = inferQuotedId(
        messages[i],
        validIds: validIds,
        posts: quotePosts,
      );
      if (inferred > 0) out[i] = inferred;
    }

    return out;
  }
}
