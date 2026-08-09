/// Quote BBCode XenForo per risposte nidificate sui commenti media.
String prependMediaQuoteBbCode({
  required int commentId,
  required String authorName,
  int authorUserId = 0,
}) {
  final username =
      authorName.replaceAll(RegExp(r'[\n\r"]'), ' ').trim();
  return '[QUOTE="$username", comment: $commentId, member: $authorUserId][/QUOTE]';
}
