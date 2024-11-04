import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;

  final double? beginValue;

  final double? endValue;

  final Duration? duration;

  final double? beginInterval;

  final double? endInterval;

  final Curve? curve;

  const FadeAnimation({
    Key? key,
    required this.child,
    this.beginValue,
    this.endValue,
    this.duration,
    this.beginInterval,
    this.endInterval,
    this.curve,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: beginValue ?? 0, end: endValue ?? 1),
        duration: duration ?? const Duration(milliseconds: 350),
        curve: Interval(
          beginInterval ?? 0,
          endInterval ?? 1,
          curve: curve ?? Curves.linear,
        ),
        builder: (context, anim, _) => Opacity(opacity: anim, child: child));
  }
}
