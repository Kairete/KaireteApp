class NewsfeedBlockFilterBar {
  String? background;
  String? minHeight;

  NewsfeedBlockFilterBar({this.background, this.minHeight});

  factory NewsfeedBlockFilterBar.fromJson(Map<String, dynamic> json) {
    return NewsfeedBlockFilterBar(
      background: json['background'] as String?,
      minHeight: json['min-height'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'background': background,
        'min-height': minHeight,
      };
}
