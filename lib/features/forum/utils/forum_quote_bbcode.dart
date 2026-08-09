import 'package:kairete/features/forum/models/forum_thread.dart';

/// Quote BBCode XenForo per risposte nidificate nel forum.
String prependForumQuoteBbCode(ForumPost quoted) {
  final username = (quoted.author?.username ?? quoted.author?.label ?? '')
      .replaceAll(RegExp(r'[\n\r"]'), ' ');
  final userId = quoted.author?.userId ?? 0;
  return '[QUOTE="$username", post: ${quoted.postId}, member: $userId][/QUOTE]';
}
