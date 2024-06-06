import 'package:kairete/features/dashboard/models/menu_item_model.dart';

import 'reaction.dart';
import 'reaction_user.dart';

class ReactionModel {
  ReactionsIcon? reaction;
  int? reactionContentId;
  int? reactionDate;
  ReactionUser? reactionUser;

  ReactionModel({
    this.reaction,
    this.reactionContentId,
    this.reactionDate,
    this.reactionUser,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) => ReactionModel(
        reaction: json['Reaction'] == null
            ? null
            : ReactionsIcon.fromJson(json['Reaction'] as Map<String, dynamic>),
        reactionContentId: json['reaction_content_id'] as int?,
        reactionDate: json['reaction_date'] as int?,
        reactionUser: json['ReactionUser'] == null
            ? null
            : ReactionUser.fromJson(
                json['ReactionUser'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'Reaction': reaction?.toJson(),
        'reaction_content_id': reactionContentId,
        'reaction_date': reactionDate,
        'ReactionUser': reactionUser?.toJson(),
      };
}
