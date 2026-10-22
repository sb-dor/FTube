import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/widget/shimmer_box.dart';

/// Cached network image with a shimmer placeholder and an asset fallback.
class NetworkImageWidget extends StatelessWidget {
  const NetworkImageWidget({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackAsset = 'assets/custom_images/error_image.png',
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(fallbackAsset, width: width, height: height, fit: fit);
    final url = this.url;
    if (url == null || url.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, _) => ShimmerBox(width: width, height: height),
      errorWidget: (context, _, _) => fallback,
    );
  }
}
