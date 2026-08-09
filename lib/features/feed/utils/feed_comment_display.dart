/// Pulizia testo commenti per la UI nidificata.
class FeedCommentDisplay {
  FeedCommentDisplay._();

  static final _bbCodeQuoteBlock = RegExp(
    r'\[QUOTE[^\]]*\].*?\[/QUOTE\]',
    caseSensitive: false,
    dotAll: true,
  );

  static final _bbCodeEmptyQuote = RegExp(
    r'\[QUOTE[^\]]*\]\s*\[/QUOTE\]',
    caseSensitive: false,
  );

  static final _bbCodeQuoteOpenTag = RegExp(
    r'\[QUOTE="([^"]*)"[^\]]*\]',
    caseSensitive: false,
  );

  static final _bbCodeUserTag = RegExp(
    r'\[USER=\d+\]([^\[]*)\[/USER\]',
    caseSensitive: false,
  );

  static final _bbCodeAnyTag = RegExp(
    r'\[/?[A-Z0-9]+(?:=[^\]]*)?\]',
    caseSensitive: false,
  );

  static final _htmlBlockquote = RegExp(
    r'<blockquote[^>]*>.*?</blockquote>',
    caseSensitive: false,
    dotAll: true,
  );

  static final _openDiv = RegExp(r'<div\b', caseSensitive: false);
  static final _closeDiv = RegExp(r'</div\s*>', caseSensitive: false);

  /// Testo mostrato per risposte nidificate: @nickname + messaggio, senza BBCode.
  static String formatNestedReplyDisplay(
    String message, {
    required bool isNested,
  }) {
    if (!isNested) return message.trim();

    final quotedUser = _extractQuotedUsername(message);
    var out = stripReplyQuote(message, isNestedReply: true);
    out = _stripBbCode(out);
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (quotedUser != null && quotedUser.isNotEmpty) {
      final mention = '@$quotedUser';
      final duplicate = RegExp(
        '^@?${RegExp.escape(quotedUser)}\\s*',
        caseSensitive: false,
      );
      out = out.replaceFirst(duplicate, '').trim();
      if (out.isEmpty) return mention;
      if (!out.startsWith('@')) return '$mention $out';
    }

    return out;
  }

  static String? _extractQuotedUsername(String message) {
    final match = _bbCodeQuoteOpenTag.firstMatch(message);
    final user = match?.group(1)?.trim();
    if (user == null || user.isEmpty) return null;
    return user;
  }

  static String _stripBbCode(String text) {
    var out = text;
    out = out.replaceAll(_bbCodeUserTag, '@\$1');
    out = out.replaceAll(_bbCodeAnyTag, '');
    return out.trim();
  }

  /// Rimuove blocchi quote da risposte nidificate (parentId > 0).
  static String stripReplyQuote(String message, {required bool isNestedReply}) {
    if (!isNestedReply) return message;
    var out = message.replaceAll(_bbCodeQuoteBlock, '');
    out = out.replaceAll(_bbCodeEmptyQuote, '');
    return out.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  }

  static String? stripReplyQuoteHtml(
    String? html, {
    required bool isNestedReply,
  }) {
    if (!isNestedReply || html == null || html.trim().isEmpty) return html;
    var out = html;
    out = _stripXenforoQuoteDivs(out);
    out = out.replaceAll(_htmlBlockquote, '');
    final trimmed = out.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _stripXenforoQuoteDivs(String html) {
    const marker = 'bbCodeBlock--quote';
    var out = html;
    var searchFrom = 0;
    while (true) {
      final markerIdx = out.indexOf(marker, searchFrom);
      if (markerIdx < 0) break;

      final divStart = out.lastIndexOf('<div', markerIdx);
      if (divStart < 0) {
        searchFrom = markerIdx + marker.length;
        continue;
      }

      final divEnd = _findMatchingCloseDiv(out, divStart);
      if (divEnd < 0) {
        searchFrom = markerIdx + marker.length;
        continue;
      }

      out = out.substring(0, divStart) + out.substring(divEnd);
      searchFrom = divStart;
    }
    return out;
  }

  static int _findMatchingCloseDiv(String html, int openStart) {
    final openEnd = html.indexOf('>', openStart);
    if (openEnd < 0) return -1;

    var pos = openEnd + 1;
    var depth = 1;

    while (pos < html.length && depth > 0) {
      final nextOpen = _openDiv.firstMatch(html.substring(pos));
      final nextClose = _closeDiv.firstMatch(html.substring(pos));

      int? openAt;
      int? closeAt;
      if (nextOpen != null) openAt = pos + nextOpen.start;
      if (nextClose != null) closeAt = pos + nextClose.start;

      if (closeAt == null && openAt == null) return -1;

      if (openAt != null && (closeAt == null || openAt < closeAt)) {
        final innerEnd = _findMatchingCloseDiv(html, openAt);
        if (innerEnd < 0) return -1;
        pos = innerEnd;
        continue;
      }

      depth--;
      if (depth == 0) {
        final closeMatch = _closeDiv.firstMatch(html.substring(pos))!;
        return pos + closeMatch.end;
      }
      final closeMatch = _closeDiv.firstMatch(html.substring(pos))!;
      pos += closeMatch.end;
    }

    return -1;
  }
}
