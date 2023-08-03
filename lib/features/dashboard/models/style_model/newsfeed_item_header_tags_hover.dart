class NewsfeedItemHeaderTagsHover {
  String? fontSize;
  String? color;
  String? fontWeight;
  String? background;

  NewsfeedItemHeaderTagsHover({
    this.fontSize,
    this.color,
    this.fontWeight,
    this.background,
  });

  factory NewsfeedItemHeaderTagsHover.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemHeaderTagsHover(
      fontSize: json['font-size'] as String?,
      color: json['color'] as String?,
      fontWeight: json['font-weight'] as String?,
      background: json['background'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'font-size': fontSize,
        'color': color,
        'font-weight': fontWeight,
        'background': background,
      };
}
