class NewsfeedItemFooterButton {
  String? fontSize;
  String? color;
  String? fontWeight;
  String? background;

  NewsfeedItemFooterButton({
    this.fontSize,
    this.color,
    this.fontWeight,
    this.background,
  });

  factory NewsfeedItemFooterButton.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemFooterButton(
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
