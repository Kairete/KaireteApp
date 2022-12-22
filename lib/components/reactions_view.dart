import 'package:flutter/material.dart';

import '../constants/color.dart';
import '../constants/color_constant.dart';
import '../features/newsfeed/models/newsfeed_model.dart';
import 'kairete_icon.dart';

class ReactionsItemView extends StatelessWidget {
  const ReactionsItemView({
    Key? key,
    required this.reactions,
  }) : super(key: key);

  final List<Reactions> reactions;

  @override
  Widget build(BuildContext context) {
    return reactions.isEmpty
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            margin: const EdgeInsets.only(top: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: kBorderDefaultColor,
              ),
              color: kECECEC,
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  const WidgetSpan(
                      child: Padding(
                    padding: EdgeInsets.only(right: 5, bottom: 1),
                    child: SvgIcon(
                      name: 'ic_like_fb',
                      width: 16,
                      height: 16,
                    ),
                  )),
                  TextSpan(
                    text: getReactionsText(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  String? getReactionsText() {
    if (reactions.isEmpty) {
      return null;
    }
    final maxCount = reactions.length > 3 ? 3 : reactions.length;
    var text = '';
    for (var i = 0; i < maxCount; i++) {
      final suffixString = i < maxCount - 1 ? ', ' : ' ';
      text += '${reactions[i].username}$suffixString';
    }
    if (reactions.length > 3) {
      text += 'and ${reactions.length - maxCount} others';
    }
    return text;
  }
}
