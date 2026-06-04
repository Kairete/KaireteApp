class Reaction {
  bool? active;
  String? imageUrl;
  int? reactionId;
  String? title;

  Reaction({this.active, this.imageUrl, this.reactionId, this.title});

  factory Reaction.fromJson(Map<String, dynamic> json) => Reaction(
        active: json['active'] as bool?,
        imageUrl: json['image_url'] as String?,
        reactionId: json['reaction_id'] as int?,
        title: json['title'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'active': active,
        'image_url': imageUrl,
        'reaction_id': reactionId,
        'title': title,
      };
}
