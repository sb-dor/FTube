import 'package:flutter/material.dart';

class _CustomShadowPainterWithClipper extends CustomPainter {
  /// the clipper class [QuadraticBezierToClipper] that we created above
  CustomClipper<Path> clipper;
  Shadow shadow;

  _CustomShadowPainterWithClipper({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    final painter = shadow.toPaint();
    final clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CustomerClipperWithShadow extends StatelessWidget {
  final CustomClipper<Path> clipper;
  final Widget child;
  final double? blurRadius;
  final Offset? offset;

  const CustomerClipperWithShadow({
    super.key,
    required this.clipper,
    required this.child,
    this.blurRadius,
    this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CustomShadowPainterWithClipper(
        shadow: Shadow(
          color: Colors.grey.shade400,
          blurRadius: blurRadius ?? 5,
          offset: offset ?? const Offset(0, 0.3),
        ),
        clipper: clipper,
      ),
      child: ClipPath(clipper: clipper, child: child),
    );
  }
}
