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
  }) : super(key: key);
  final String url;
  final double? width;
  final double? height;
  final bool isCircle;
  final String? nameImage;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return url == ""
        ? (nameImage != null
            ? Container(
                width: width,
                height: height,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: kPrimaryColor),
                child: Center(
                  child: Text(
                    nameImage
                            ?.replaceAll(' ', '')
                            .substring(0, 1)
                            .toUpperCase() ??
                        '',
                    style: kTextMediumtStyle.copyWith(
                      fontSize: fontSize ?? 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : SizedBox())
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
