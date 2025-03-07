import 'package:flutter/material.dart';

class SlideAnimation extends StatelessWidget {
  final Widget child;
  final Offset? begin;
  final Offset? end;
  final Duration? duration;

  final double? intervalBegin;
  final double? intervalEnd;
  final Curves? curves;

  const SlideAnimation({
    super.key,
    required this.child,
    this.begin,
    this.end,
    this.duration,
    this.intervalBegin,
    this.intervalEnd,
    this.curves,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: begin ?? const Offset(200, 0), end: end ?? const Offset(0, 0)),
      duration: duration ?? const Duration(milliseconds: 750),
      curve: Interval(intervalBegin ?? 0, intervalEnd ?? 1, curve: Curves.linear),
      builder: (context, animation, widget) => Transform.translate(offset: animation, child: child),
    );
  }
}
