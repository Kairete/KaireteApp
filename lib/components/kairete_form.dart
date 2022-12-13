import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/color_constant.dart';
import '../constants/font_constant.dart';
import 'kairete_icon.dart';

// ignore: must_be_immutable
class KaireteFormLine extends StatefulWidget {
  KaireteFormLine(
      {Key? key,
      this.width,
      this.height,
      this.placerholder,
      this.obscureText = false,
      this.suffixIcon,
      this.errorText,
      required this.onChanged,
      this.controller,
      this.inputType,
      this.text,
      this.debounceTime,
      this.formatter,
      this.maxLenght,
      this.onFieldSubmitted,
      this.focusNode})
      : super(key: key);

  final double? width;
  final double? height;
  final String? placerholder;
  bool obscureText;
  final Widget? suffixIcon;
  final String? errorText;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final String? text;
  final int? debounceTime;
  final List<TextInputFormatter>? formatter;
  final int? maxLenght;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  State<KaireteFormLine> createState() => _KaireteFormLineState();
}

class _KaireteFormLineState extends State<KaireteFormLine> {
  bool? obscureText;
  String currentText = '';
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: kTextMediumtStyle,
      onChanged: (value) {
        timer?.cancel();
        timer = Timer(
          Duration(milliseconds: widget.debounceTime ?? 500),
          () {
            widget.onChanged(value);
          },
        );
        setState(() {
          currentText = value;
        });
      },
      key: Key(widget.text ?? ''),
      initialValue: widget.text,
      keyboardType: widget.inputType,
      controller: widget.controller,
      maxLength: widget.maxLenght,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      inputFormatters: widget.formatter ??
          (widget.inputType == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : []),
      decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kBorderDefaultColor),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kTextPrimaryColor),
          ),
          hintText: widget.placerholder,
          errorText: widget.errorText,
          errorMaxLines: 2,
          suffixIcon: widget.suffixIcon ??
              (widget.obscureText
                  ? (currentText == ''
                      ? const SizedBox()
                      : IconButton(
                          icon: SvgIcon(
                            name: (obscureText ?? widget.obscureText)
                                ? 'ic_pass'
                                : 'ic_hide_pass',
                            width: 24,
                            height: 14,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText ??= widget.obscureText;
                              obscureText = !obscureText!;
                            });
                          },
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                        ))
                  : null),
          hintStyle: kTextMediumtStyle.copyWith(color: kTextSubduedColor),
          focusColor: kIconPrimaryColor),
      obscureText: obscureText ?? widget.obscureText,
      cursorColor: kIconPrimaryColor,
    );
  }
}

class KaireteTextField extends StatelessWidget {
  const KaireteTextField(
      {Key? key,
      this.title,
      this.hint,
      this.errorText,
      this.subTitle,
      this.controller,
      required this.onChanged,
      this.keyboardType,
      this.autoFocus = false,
      this.hintColor,
      this.readOnly = false,
      this.backgroundColor,
      this.prefixIcon,
      this.suffixIcon,
      this.onTap,
      this.text,
      this.textStyle,
      this.maxLine = 1,
      this.borderColor,
      this.isRequired = false,
      this.suffixTitle,
      this.crossTitle,
      this.textCapitalization,
      this.inputFormater,
      this.maxLenght,
      this.textInputAction,
      this.debounceTime,
      this.isDisable = false,
      this.onFieldSubmitted,
      this.focusNode})
      : super(key: key);

  final String? title;
  final String? hint;
  final String? errorText;
  final String? subTitle;
  final TextEditingController? controller;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final bool autoFocus;
  final Color? hintColor;
  final bool readOnly;
  final Color? backgroundColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Function? onTap;
  final String? text;
  final TextStyle? textStyle;
  final int? maxLine;
  final Color? borderColor;
  final bool isRequired;
  final Widget? suffixTitle;
  final CrossAxisAlignment? crossTitle;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormater;
  final int? maxLenght;
  final TextInputAction? textInputAction;
  final int? debounceTime;
  final bool isDisable;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    Timer? timer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  crossAxisAlignment: crossTitle ?? CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? '',
                      style: kTextMediumtStyle.copyWith(fontSize: 14),
                    ),
                    if (suffixTitle != null) suffixTitle!,
                    if (isRequired)
                      Text(
                        ' *',
                        style: kTextRegularStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            color: kTextCriticalColor),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        TextFormField(
          onChanged: (value) {
            timer?.cancel();
            timer = Timer(
              Duration(milliseconds: debounceTime ?? 500),
              () {
                onChanged(value);
              },
            );
          },
          textInputAction: textInputAction,
          inputFormatters: inputFormater ??
              (keyboardType == TextInputType.number
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : []),
          textCapitalization: textCapitalization ?? TextCapitalization.none,
          controller: controller,
          keyboardType: keyboardType,
          autofocus: autoFocus,
          readOnly: isDisable ? isDisable : readOnly,
          initialValue: text,
          maxLength: maxLenght,
          onFieldSubmitted: onFieldSubmitted,
          focusNode: focusNode,
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
          },
          onEditingComplete: () {},
          style: textStyle ??
              kTextMediumtStyle.copyWith(
                  fontSize: 14,
                  color: isDisable ? kTextDisabledColor : kTextDefaultColor),
          key: Key(text ?? ''),
          maxLines: maxLine,
          decoration: InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hint ?? '',
              hintStyle: kTextMediumtStyle.copyWith(
                  fontSize: 14, color: hintColor ?? kTextSubduedColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: borderColor ?? kBorderDefaultColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: borderColor ?? kBorderPrimaryColor),
              ),
              filled: true,
              errorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: borderColor ?? kSurfaceCriticalColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                borderSide:
                    BorderSide(color: borderColor ?? kBorderPrimaryColor),
              ),
              errorText: errorText == '' ? null : errorText,
              errorStyle: kTextRegularStyle.copyWith(
                  fontSize: 12, color: kSurfaceCriticalColor),
              fillColor: isDisable
                  ? kSurfaceDisabledColor
                  : backgroundColor ?? kSurfaceLightSubdueColor),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Text(
            subTitle ?? '',
            style: kTextRegularStyle.copyWith(
                fontSize: 12, color: kTextMediumColor),
          ),
        )
      ],
    );
  }
}

class KairetePassWordTextField extends StatefulWidget {
  const KairetePassWordTextField(
      {Key? key,
      this.title,
      this.hint,
      this.errorText,
      this.subTitle,
      this.controller,
      required this.onChanged,
      this.keyboardType,
      this.isRequired = false,
      this.maxLenght})
      : super(key: key);

  final String? title;
  final String? hint;
  final String? errorText;
  final String? subTitle;
  final TextEditingController? controller;
  final Function(String) onChanged;
  final TextInputType? keyboardType;
  final bool isRequired;
  final int? maxLenght;

  @override
  State<KairetePassWordTextField> createState() =>
      _KairetePassWordTextFieldState();
}

class _KairetePassWordTextFieldState extends State<KairetePassWordTextField> {
  bool obscureText = true;
  String currentText = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 12),
                child: Row(
                  children: [
                    Text(
                      widget.title ?? '',
                      style: kTextMediumtStyle.copyWith(fontSize: 14),
                    ),
                    if (widget.isRequired)
                      Text(
                        ' *',
                        style: kTextRegularStyle.copyWith(
                            fontWeight: FontWeight.w500,
                            color: kTextCriticalColor),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        TextFormField(
          onChanged: (value) {
            widget.onChanged(value);
            setState(() {
              currentText = value;
            });
          },
          controller: widget.controller,
          obscureText: obscureText,
          maxLength: widget.maxLenght,
          decoration: InputDecoration(
              suffixIcon: currentText == ''
                  ? const SizedBox()
                  : IconButton(
                      icon: SvgIcon(
                        name: obscureText ? 'ic_pass' : 'ic_hide_pass',
                        width: 24,
                        height: 14,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    ),
              hintText: widget.hint ?? '',
              hintStyle: kTextMediumtStyle.copyWith(
                  fontSize: 14, color: kTextSubduedColor),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: kBorderDefaultColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: kBorderPrimaryColor),
              ),
              filled: true,
              errorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: kSurfaceCriticalColor),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: kBorderPrimaryColor),
              ),
              errorText: (widget.errorText == '' || widget.errorText == null)
                  ? null
                  : widget.errorText,
              errorStyle: kTextRegularStyle.copyWith(
                  fontSize: 12, color: kSurfaceCriticalColor),
              fillColor: kSurfaceLightSubdueColor),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: Text(
            widget.subTitle ?? '',
            style: kTextRegularStyle.copyWith(
                fontSize: 12, color: kTextMediumColor),
          ),
        )
      ],
    );
  }
}
