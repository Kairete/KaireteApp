import 'css.dart';

class StyleModel {
  Css? css;

  StyleModel({this.css});

  factory StyleModel.fromJson(Map<String, dynamic> json) => StyleModel(
        css: json['css'] == null
            ? null
            : Css.fromJson(json['css'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'css': css?.toJson(),
      };
}
