class NewsfeedItemReactionsBar {
  String? fontSize;
  String? color;
  String? fontWeight;
  String? background;
  String? border;
  String? borderTop;
  String? borderRight;
  String? borderBottom;
  String? borderLeft;
  String? paddingTop;
  String? paddingRight;
  String? paddingBottom;
  String? paddingLeft;

  NewsfeedItemReactionsBar({
    this.fontSize,
    this.color,
    this.fontWeight,
    this.background,
    this.border,
    this.borderTop,
    this.borderRight,
    this.borderBottom,
    this.borderLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingLeft,
  });

  factory NewsfeedItemReactionsBar.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemReactionsBar(
      fontSize: json['font-size'] as String?,
      color: json['color'] as String?,
      fontWeight: json['font-weight'] as String?,
      background: json['background'] as String?,
      border: json['border'] as String?,
      borderTop: json['border-top'] as String?,
      borderRight: json['border-right'] as String?,
      borderBottom: json['border-bottom'] as String?,
      borderLeft: json['border-left'] as String?,
      paddingTop: json['padding-top'] as String?,
      paddingRight: json['padding-right'] as String?,
      paddingBottom: json['padding-bottom'] as String?,
      paddingLeft: json['padding-left'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'font-size': fontSize,
        'color': color,
        'font-weight': fontWeight,
        'background': background,
        'border': border,
        'border-top': borderTop,
        'border-right': borderRight,
        'border-bottom': borderBottom,
        'border-left': borderLeft,
        'padding-top': paddingTop,
        'padding-right': paddingRight,
        'padding-bottom': paddingBottom,
        'padding-left': paddingLeft,
      };
}
