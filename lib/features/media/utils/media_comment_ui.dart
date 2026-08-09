import 'package:kairete/core/utils/json_parse.dart';
import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/media/models/media_comment.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

List<FeedNestedCommentData> mapMediaCommentsToNested(
  List<MediaComment> comments,
) {
  if (comments.isEmpty) return const [];

  final ids = comments.map((c) => c.commentId).where((id) => id > 0).toList();
  if (ids.isEmpty) return const [];

  final parents = comments.map((c) => c.parentCommentId).toList();
  final depths = comments.map((c) => c.depth).toList();
  var enrichedParents = FeedCommentParent.inferParentsFromDepth(
    ids: comments.map((c) => c.commentId).toList(),
    parentIds: parents,
    depths: depths,
  );

  final out = <FeedNestedCommentData>[];
  for (var i = 0; i < comments.length; i++) {
    final comment = comments[i];
    if (comment.commentId <= 0) continue;
    final parentId = enrichedParents[i];
    final depth = _depthForComment(
      index: i,
      parentId: parentId,
      depthHint: comment.depth,
      enrichedParents: enrichedParents,
    );
    out.add(
      FeedNestedCommentData(
        id: comment.commentId,
        parentId: parentId,
        depthHint: depth,
        authorName:
            comment.author?.label ?? comment.author?.username ?? '',
        avatarUrl: comment.author?.avatarUrl,
        dateLabel: formatFeedCommentDate(comment.commentDate),
        message: comment.messagePlainText ?? '',
        likeCount: comment.reactionScore,
        visitorReactionId: comment.visitorReactionId,
        canReply: nestedCommentCanReply(depth),
      ),
    );
  }
  return out;
}

int _depthForComment({
  required int index,
  required int parentId,
  required int depthHint,
  required List<int> enrichedParents,
}) {
  if (depthHint > 0) return depthHint;
  if (parentId <= 0) return 0;
  return 1;
}

Map<int, int> parseMediaCommentParentMap(Map<String, dynamic> json) {
  final raw = json['parents'];
  if (raw is! Map) return const {};

  final map = <int, int>{};
  raw.forEach((key, value) {
    final commentId = JsonParse.intValue(key);
    final parentId = JsonParse.intValue(value);
    if (commentId > 0 && parentId > 0 && parentId != commentId) {
      map[commentId] = parentId;
    }
  });
  return map;
}
