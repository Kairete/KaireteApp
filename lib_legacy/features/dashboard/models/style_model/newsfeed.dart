class Newsfeed {
  String? background;
  String? borderColor;

  Newsfeed({this.background, this.borderColor});

  factory Newsfeed.fromJson(Map<String, dynamic> json) => Newsfeed(
        background: json['background'] as String?,
        borderColor: json['border-color'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'background': background,
        'border-color': borderColor,
      };
}
