class NewsfeedItemHeaderUsername {
  String? fontSize;
  String? color;
  String? fontWeight;

  NewsfeedItemHeaderUsername({this.fontSize, this.color, this.fontWeight});

  factory NewsfeedItemHeaderUsername.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemHeaderUsername(
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
