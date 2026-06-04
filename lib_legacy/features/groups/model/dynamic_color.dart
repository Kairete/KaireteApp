class DynamicColor {
  String? bgColor;
  String? color;
  String? innerContent;

  DynamicColor({this.bgColor, this.color, this.innerContent});

  factory DynamicColor.fromJson(Map<String, dynamic> json) => DynamicColor(
        bgColor: json['bgColor'] as String?,
        color: json['color'] as String?,
        innerContent: json['innerContent'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'bgColor': bgColor,
        'color': color,
        'innerContent': innerContent,
      };
}
