import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:shimmer/shimmer.dart';

class ImageLoaderWidget extends StatelessWidget {
  final String url;
  final String errorImageUrl;
  final String? imageBlurHash;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final EdgeInsets? marginShimmerContainer;
  final EdgeInsets? paddingShimmerContainer;
  final BorderRadius? borderRadius;

  const ImageLoaderWidget(
      {Key? key,
      required this.url,
      this.errorImageUrl = 'assets/custom_images/custom_user_image.png',
      this.imageBlurHash,
      this.height,
      this.width,
      this.boxFit,
      this.marginShimmerContainer,
      this.paddingShimmerContainer,
      this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: url,
        width: width,
        httpHeaders: const {
          "Accept": "application/json",
          "Connection": "Keep-Alive",
          "Keep-Alive": "timeout=10, max=1000"
        },
        fit: boxFit ?? BoxFit.scaleDown,
        placeholder: (context, url) {
          if (imageBlurHash != null) {
            return Container(
                margin: marginShimmerContainer,
                padding: paddingShimmerContainer,
                width: width,
                height: height,
                decoration: BoxDecoration(borderRadius: borderRadius),
                child: BlurHash(
                  hash: imageBlurHash ?? 'L00w16X:L#qZf,fke.e.HXm*y?UH',
                  imageFit: boxFit ?? BoxFit.scaleDown,
                  duration: const Duration(seconds: 2),
                  curve: Curves.linear,
                ));
          }
          return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.white,
              child: Container(
                  margin: marginShimmerContainer,
                  padding: paddingShimmerContainer,
                  width: width,
                  height: height,
                  decoration:
                      BoxDecoration(color: Colors.grey.shade200, borderRadius: borderRadius)));
        },
        errorWidget: (context, url, error) => Image.asset(errorImageUrl,
            height: height, width: width, fit: boxFit ?? BoxFit.scaleDown));
  }
}
