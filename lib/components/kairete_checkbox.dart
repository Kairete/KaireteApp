import 'package:flutter/material.dart';
import 'package:kairete/constants/color.dart';

import '../constants/color_constant.dart';
import '../constants/font_constant.dart';

// ignore: must_be_immutable
class KaireteCheckBox extends StatefulWidget {
  KaireteCheckBox({
    Key? key,
    this.title,
    this.onChanged,
    this.value,
    this.enable = true,
    this.isStart = true,
    this.titleStyle,
  }) : super(key: key);

  final String? title;
  final Function(bool?)? onChanged;
  bool? value;
  final bool isStart;
  final bool enable;
  final TextStyle? titleStyle;

  @override
  State<KaireteCheckBox> createState() => _KaireteCheckBoxState();
}

class _KaireteCheckBoxState extends State<KaireteCheckBox> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.isStart)
          Transform.scale(
            scale: 1.2,
            child: SizedBox(
              width: 20,
              height: 20,
              child: Theme(
                data: ThemeData(unselectedWidgetColor: kBorderDividerColor),
                child: Checkbox(
                  checkColor: Colors.white,
                  activeColor: kPrimaryColor,
                  value: widget.value ?? false,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  onChanged: (bool? value) {
                    setState(() {
                      widget.value = value;
                    });
                    widget.onChanged!(value);
                  },
                ),
              ),
            ),
          ),
        if (widget.isStart)
          const SizedBox(
            width: 8,
          ),
        Expanded(
          child: Text(
            widget.title ?? 'Lưu thông tin người nhận cho lần gửi sau.',
            style:
                widget.titleStyle ?? kTextRegularStyle.copyWith(fontSize: 17),
          ),
        ),
        if (!widget.isStart)
          Transform.scale(
            scale: 1.2,
            child: SizedBox(
              width: 20,
              height: 20,
              child: Theme(
                data: ThemeData(unselectedWidgetColor: kBorderDividerColor),
                child: Checkbox(
                  checkColor: Colors.white,
                  activeColor: kPrimaryColor,
                  value: widget.value ?? false,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  onChanged: (bool? value) {
                    setState(() {
                      widget.value = value;
                    });
                    widget.onChanged!(value);
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
