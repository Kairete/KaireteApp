import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../constants/font_constant.dart';

class KaireteSearchField extends StatelessWidget {
  const KaireteSearchField({
    Key? key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hint,
    this.keyboardType,
  }) : super(key: key);

  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: kBorderDefaultColor),
          color: kSurfaceLightSubdueColor),
      child: TextField(
        style: kTextMediumtStyle.copyWith(fontSize: 14),
        cursorColor: kIconPrimaryColor,
        controller: controller,
        onChanged: (value) {
          onChanged!(value);
        },
        onSubmitted: (value) {
          if (onSubmitted != null) {
            onSubmitted!(value);
          }
        },
        keyboardType: keyboardType,
        decoration: InputDecoration(
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintStyle: kTextMediumtStyle.copyWith(
                color: kTextSubduedColor, fontSize: 14),
            hintText: hint ?? 'Search...'),
      ),
    );
  }
}
