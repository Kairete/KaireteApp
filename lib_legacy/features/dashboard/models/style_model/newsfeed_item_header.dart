class NewsfeedItemHeader {
  String? fontSize;
  String? color;
  String? fontWeight;
  String? borderColor;
  String? borderTopColor;
  String? borderRightColor;
  String? borderBottomColor;
  String? borderLeftColor;

  NewsfeedItemHeader({
    this.fontSize,
    this.color,
    this.fontWeight,
    this.borderColor,
    this.borderTopColor,
    this.borderRightColor,
    this.borderBottomColor,
    this.borderLeftColor,
  });

  factory NewsfeedItemHeader.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemHeader(
      fontSize: json['font-size'] as String?,
      color: json['color'] as String?,
      fontWeight: json['font-weight'] as String?,
      borderColor: json['border-color'] as String?,
      borderTopColor: json['border-top-color'] as String?,
      borderRightColor: json['border-right-color'] as String?,
      borderBottomColor: json['border-bottom-color'] as String?,
      borderLeftColor: json['border-left-color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'font-size': fontSize,
        'color': color,
        'font-weight': fontWeight,
        'border-color': borderColor,
        'border-top-color': borderTopColor,
        'border-right-color': borderRightColor,
        'border-bottom-color': borderBottomColor,
        'border-left-color': borderLeftColor,
      };
}
