import 'package:kairete/features/feed/utils/feed_comment_parent.dart';
import 'package:kairete/features/feed/utils/feed_comment_tree.dart';
import 'package:kairete/features/feed/widgets/feed_nested_comment_thread.dart';
import 'package:kairete/features/omnifeed/models/omnifeed_comment.dart';
import 'package:kairete/features/omnifeed/utils/omnifeed_time.dart';

List<FeedNestedCommentData> mapOmnifeedCommentsToNested(
  List<OmnifeedComment> comments,
) {
  if (comments.isEmpty) return const [];

  final ids = comments.map((c) => c.commentId).toList();
  final parents = comments.map((c) => c.parentCommentId).toList();
  final depths = comments.map((c) => c.depth).toList();
  final enrichedParents = FeedCommentParent.inferParentsFromDepth(
    ids: ids,
    parentIds: parents,
    depths: depths,
  );

  final out = <FeedNestedCommentData>[];
  for (var i = 0; i < comments.length; i++) {
    final comment = comments[i];
    if (comment.commentId <= 0) continue;
    final parentId = enrichedParents[i];
    final depth = comment.depth > 0
        ? comment.depth
        : (parentId > 0 ? 1 : 0);
    out.add(
      FeedNestedCommentData(
        id: comment.commentId,
        parentId: parentId,
        depthHint: depth,
        authorName:
            comment.author?.label ?? comment.author?.username ?? '',
        avatarUrl: comment.author?.avatarUrl,
        dateLabel: formatFeedCommentDate(comment.commentDate),
        message: comment.messagePlainText,
        likeCount: comment.reactionScore,
        visitorReactionId: comment.visitorReactionId,
        canReply: nestedCommentCanReply(depth),
      ),
    );
  }
  return out;
}
