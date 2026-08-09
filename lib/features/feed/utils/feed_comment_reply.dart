import 'package:flutter/material.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';

/// Stato della risposta a un commento nidificato (barra in basso con @nickname).
class FeedCommentReplyDraft {
  int? parentCommentId;
  String? authorName;

  bool get isActive =>
      parentCommentId != null &&
      parentCommentId! > 0 &&
      authorName != null &&
      authorName!.trim().isNotEmpty;

  void begin({required int parentCommentId, required String authorName}) {
    this.parentCommentId = parentCommentId;
    this.authorName = authorName.trim();
  }

  void beginFrom(FeedNestedCommentData comment) {
    begin(parentCommentId: comment.id, authorName: comment.authorName);
  }

  void clear() {
    parentCommentId = null;
    authorName = null;
  }

  String? get replyLabel => isActive ? 'Risposta a @$authorName' : null;

  String mentionPrefix() => isActive ? '@$authorName ' : '';

  /// Testo da inviare all'API (senza @ prefissato in composer).
  String messageForApi(String raw) {
    var text = raw.trim();
    if (!isActive) return text;
    final prefix = mentionPrefix();
    if (text.startsWith(prefix)) {
      text = text.substring(prefix.length).trim();
    } else {
      final shortPrefix = '@$authorName';
      if (text.startsWith(shortPrefix)) {
        text = text.substring(shortPrefix.length).trim();
      }
    }
    return text;
  }

  void primeComposer(TextEditingController controller) {
    if (!isActive) return;
    final prefix = mentionPrefix();
    controller.value = TextEditingValue(
      text: prefix,
      selection: TextSelection.collapsed(offset: prefix.length),
    );
  }
}

/// Individua il commento appena creato dopo un reload della lista.
int? detectNewNestedCommentId({
  required Iterable<int> previousIds,
  required List<FeedNestedCommentData> current,
  required int parentCommentId,
}) {
  final before = previousIds.toSet();
  for (var i = current.length - 1; i >= 0; i--) {
    final comment = current[i];
    if (comment.parentId == parentCommentId && !before.contains(comment.id)) {
      return comment.id;
    }
  }
  return null;
}
