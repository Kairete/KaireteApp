import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kairete/constants/color.dart';
import 'package:kairete/constants/font_constant.dart';

import '../constants/color_constant.dart';

class KaireteCacheNetworkImage extends StatelessWidget {
  const KaireteCacheNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.isCircle = false,
    this.nameImage,
    this.fontSize,
    this.borderRadius,
  }) : super(key: key);
  final String url;
  final double? width;
  final double? height;
  final bool isCircle;
  final String? nameImage;
  final double? fontSize;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    print('======11 $nameImage');
    return url == ""
        ? (nameImage != null
            ? Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                    shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                    color: kPrimaryColor),
                child: Center(
                  child: Text(
                    nameImage!.isNotEmpty ? nameImage![0] : '',
                    style: kTextMediumtStyle.copyWith(
                      fontSize: fontSize ?? 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : const SizedBox())
        : CachedNetworkImage(
            imageUrl: url,
            imageBuilder: (context, imageProvider) => Container(
              height: height ?? 200,
              width: width,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                  borderRadius: borderRadius,
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
