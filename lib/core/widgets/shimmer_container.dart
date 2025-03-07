import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final Duration? duration;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.child,
    this.backgroundColor,
    this.borderRadius,
    this.duration,
  });

  const ShimmerContainer.withChild({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.white,
      period: duration ?? const Duration(milliseconds: 1500),
      child:
          child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white,
              borderRadius: borderRadius,
            ),
          ),
    );
  }
}
