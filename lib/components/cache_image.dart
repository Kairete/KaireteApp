import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/color_constant.dart';

class KaireteCacheNetworkImage extends StatelessWidget {
  const KaireteCacheNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.isCircle = false,
  }) : super(key: key);
  final String url;
  final double? width;
  final double? height;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return url == ""
        ? SizedBox()
        : CachedNetworkImage(
            imageUrl: url,
            imageBuilder: (context, imageProvider) => Container(
              height: height ?? 200,
              width: width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle),
            ),
            errorWidget: (context, error, _) {
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kBorderDefaultColor,
                ),
              );
            },
          );
  }
}
