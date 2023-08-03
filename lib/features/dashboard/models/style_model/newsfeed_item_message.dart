class NewsfeedItemMessage {
  String? marginBottom;

  NewsfeedItemMessage({this.marginBottom});

  factory NewsfeedItemMessage.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemMessage(
      marginBottom: json['margin-bottom'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'margin-bottom': marginBottom,
      };
}
