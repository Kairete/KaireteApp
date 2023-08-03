class NewsfeedItemHeaderTitle {
  String? fontSize;
  String? color;
  String? fontWeight;

  NewsfeedItemHeaderTitle({this.fontSize, this.color, this.fontWeight});

  factory NewsfeedItemHeaderTitle.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemHeaderTitle(
      fontSize: json['font-size'] as String?,
      color: json['color'] as String?,
      fontWeight: json['font-weight'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'font-size': fontSize,
        'color': color,
        'font-weight': fontWeight,
      };
}
