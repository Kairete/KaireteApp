import 'package:get/get.dart';

import '../../../../helper/user.dart';
import '../../../../local/master_data.dart';
import '../newsfeed_model.dart';

class Comment {
  bool? canDelete;
  bool? canEdit;
  bool? canReact;
  bool? canReply;
  bool? canReport;
  int? commentId;
  int? commentLevel;
  bool? hasMoreReplies;
  bool? isIgnored;
  bool? isReactedTo;
  String? messageParsed;
  String? messagePlainText;
  int? reactionScore;
  User? user;
  String? viewUrl;
  List<Reactions>? reactions;
  String? reactionIconUrl;

  Comment(
      {this.canDelete,
      this.canEdit,
      this.canReact,
      this.canReply,
      this.canReport,
      this.commentId,
      this.commentLevel,
      this.hasMoreReplies,
      this.isIgnored,
      this.isReactedTo,
      this.messageParsed,
      this.messagePlainText,
      this.reactionScore,
      this.reactions,
      this.user,
      this.viewUrl});

  Comment.fromJson(Map<String, dynamic> json) {
    canDelete = json['can_delete'];
    canEdit = json['can_edit'];
    canReact = json['can_react'];
    canReply = json['can_reply'];
    canReport = json['can_report'];
    commentId = json['comment_id'];
    commentLevel = json['comment_level'];
    hasMoreReplies = json['has_more_replies'];
    isIgnored = json['is_ignored'];
    isReactedTo = json['is_reacted_to'];

    messageParsed = json['message_parsed'];
    messagePlainText = json['message_plain_text'];
    reactionScore = json['reaction_score'];
    if (json['reactions'] != null) {
      reactions = <Reactions>[];
      json['reactions'].forEach((v) {
        reactions!.add(Reactions.fromJson(v));
      });
    }
    user = json['User'] != null ? User.fromJson(json['User']) : null;
    viewUrl = json['view_url'];
    if (reactions != null) {
      final userId = UserManager.instance.userId;
      final item =
          reactions!.firstWhereOrNull((element) => element.userId == userId);
      if (item != null) {
        final path = MasterDataManager.instance.reactionIcons
            .firstWhere((element) => element.reactionId == item.reactionId)
            .imageUrl;
        reactionIconUrl = path;
      }
    }
  }

  // factory Comment.fromJson(Map<String, dynamic> json) => Comment(
  //     canEdit: json['can_edit'] as bool?,
  //     canHardDelete: json['can_hard_delete'] as bool?,
  //     canReact: json['can_react'] as bool?,
  //     canSoftDelete: json['can_soft_delete'] as bool?,
  //     canViewAttachments: json['can_view_attachments'] as bool?,
  //     commentDate: json['comment_date'] as int?,
  //     isReactedTo: json['is_reacted_to'] as bool?,
  //     message: json['message'] as String?,
  //     messageParsed: json['message_parsed'] as String?,
  //     messageState: json['message_state'] as String?,
  //     profilePostCommentId: json['profile_post_comment_id'] as int?,
  //     profilePostId: json['profile_post_id'] as int?,
  //     reactionScore: json['reaction_score'] as int?,
  //     user: json['User'] == null
  //         ? null
  //         : User.fromJson(json['User'] as Map<String, dynamic>),
  //     userId: json['user_id'] as int?,
  //     username: json['username'] as String?,
  //     viewUrl: json['view_url'] as String?,
  //     warningMessage: json['warning_message'] as String?,
  //     commentId: json['comment_id'] as int?,
  //     reactions: (json['reactions'] as List<dynamic>?)
  //         ?.map((e) => Reactions.fromJson(e as Map<String, dynamic>))
  //         .toList());

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['can_delete'] = canDelete;
    data['can_edit'] = canEdit;
    data['can_react'] = canReact;
    data['can_reply'] = canReply;
    data['can_report'] = canReport;
    data['comment_id'] = commentId;
    data['comment_level'] = commentLevel;
    data['has_more_replies'] = hasMoreReplies;
    data['is_ignored'] = isIgnored;
    data['is_reacted_to'] = isReactedTo;

    data['message_parsed'] = messageParsed;
    data['message_plain_text'] = messagePlainText;
    data['reaction_score'] = reactionScore;
    if (reactions != null) {
      data['reactions'] = reactions!.map((v) => v.toJson()).toList();
    }
    if (user != null) {
      data['User'] = user!.toJson();
    }
    data['view_url'] = viewUrl;
    return data;
  }
}
