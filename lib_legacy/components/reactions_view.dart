import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kairete/helper/extenstions.dart';
import 'package:supercharged/supercharged.dart';

import '../constants/color.dart';
import '../constants/color_constant.dart';
import '../features/dashboard/controllers/dashboard_controller.dart';
import '../features/dashboard/models/style_model/css.dart';
import '../features/newsfeed/models/newsfeed_model.dart';
import 'kairete_icon.dart';

// ignore: must_be_immutable
class ReactionsItemView extends StatelessWidget {
  ReactionsItemView({
    Key? key,
    required this.reactions,
  }) : super(key: key);

  final List<Reactions> reactions;
  Css? style = Get.find<DashboardController>().style;

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
                color: style?.newsfeedItemReactionsBar?.background.toColor() ??
                    Color(0xFFE7E7E7),
              ),
              color: style?.newsfeedItemReactionsBar?.background.toColor() ??
                  kECECEC,
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
                    style: TextStyle(
                      fontWeight: style?.newsfeedItemReactionsBar?.fontWeight
                              ?.getWegiht() ??
                          FontWeight.w600,
                      color:
                          style?.newsfeedItemReactionsBar?.color?.toColor() ??
                              kPrimaryColor,
                      fontSize: style?.newsfeedItemReactionsBar?.fontSize
                              .parseDouble() ??
                          16,
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
