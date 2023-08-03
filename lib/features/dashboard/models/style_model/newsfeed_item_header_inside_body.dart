class NewsfeedItemHeaderInsideBody {
  String? fontSize;
  String? color;
  String? fontWeight;
  String? background;
  String? border;
  String? borderTopWidth;
  String? borderRightWidth;
  String? borderBottomWidth;
  String? borderLeftWidth;
  String? borderRadius;
  String? padding;
  String? paddingTop;
  String? paddingRight;
  String? paddingBottom;
  String? paddingLeft;
  String? marginBottom;

  NewsfeedItemHeaderInsideBody({
    this.fontSize,
    this.color,
    this.fontWeight,
    this.background,
    this.border,
    this.borderTopWidth,
    this.borderRightWidth,
    this.borderBottomWidth,
    this.borderLeftWidth,
    this.borderRadius,
    this.padding,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingLeft,
    this.marginBottom,
  });

  factory NewsfeedItemHeaderInsideBody.fromJson(Map<String, dynamic> json) {
    return NewsfeedItemHeaderInsideBody(
      fontSize: json['font-size'] as String?,
      color: json['color'] as String?,
      fontWeight: json['font-weight'] as String?,
      background: json['background'] as String?,
      border: json['border'] as String?,
      borderTopWidth: json['border-top-width'] as String?,
      borderRightWidth: json['border-right-width'] as String?,
      borderBottomWidth: json['border-bottom-width'] as String?,
      borderLeftWidth: json['border-left-width'] as String?,
      borderRadius: json['border-radius'] as String?,
      padding: json['padding'] as String?,
      paddingTop: json['padding-top'] as String?,
      paddingRight: json['padding-right'] as String?,
      paddingBottom: json['padding-bottom'] as String?,
      paddingLeft: json['padding-left'] as String?,
      marginBottom: json['margin-bottom'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'font-size': fontSize,
        'color': color,
        'font-weight': fontWeight,
        'background': background,
        'border': border,
        'border-top-width': borderTopWidth,
        'border-right-width': borderRightWidth,
        'border-bottom-width': borderBottomWidth,
        'border-left-width': borderLeftWidth,
        'border-radius': borderRadius,
        'padding': padding,
        'padding-top': paddingTop,
        'padding-right': paddingRight,
        'padding-bottom': paddingBottom,
        'padding-left': paddingLeft,
        'margin-bottom': marginBottom,
      };
}
