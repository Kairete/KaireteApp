import 'dart:ui';

extension DoubleParser on String? {
  int parseInt() {
    return int.parse(this ?? '0');
  }

  double? parseDouble() {
    if (this != null) {
      return double.parse(this!.replaceAll('px', ''));
    }
    return null;
  }

  Color? toColor() {
    if (this == null) {
      return null;
    }
    final buffer = StringBuffer();
    if (this!.length == 6 || this!.length == 7) buffer.write('ff');
    buffer.write(this!.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  FontWeight? getWegiht() {
    if (this != null) {
      return null;
    }
    switch (this) {
      case '700':
        return FontWeight.w700;
      case '600':
        return FontWeight.w600;
      case '500':
        return FontWeight.w500;
      case '400':
        return FontWeight.w400;
      case '300':
        return FontWeight.w300;
      case '200':
        return FontWeight.w200;
      default:
    }
  }
}
