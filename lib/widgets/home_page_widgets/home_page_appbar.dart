import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// CustomShadowPainterWithClipper
// https://gist.github.com/coman3/e631fd55cd9cdf9bd4efe8ecfdbb85a7
class QuadraticBezierToClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 0);

    path.lineTo(0, size.height - 40);

    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class CustomShadowPainterWithClipper extends CustomPainter {
  /// the clipper class [QuadraticBezierToClipper] that we created above
  CustomClipper<Path> clipper;
  Shadow shadow;

  CustomShadowPainterWithClipper({required this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var painter = shadow.toPaint();
    var clipPath = clipper.getClip(size).shift(shadow.offset);
    canvas.drawPath(clipPath, painter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HomePageAppBar extends StatelessWidget {
  const HomePageAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CustomShadowPainterWithClipper(
          shadow: Shadow(
            color: Colors.grey.shade400,
            blurRadius: 5,
            offset: const Offset(0, 0.3),
          ),
          clipper: QuadraticBezierToClipper()),
      child: ClipPath(
        clipper: QuadraticBezierToClipper(),
        child: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          title: const Text("FTube", style: TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => [],
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.black,
              ),
            )
          ],
          leading: IconButton(
            onPressed: () => [],
            icon: const Icon(Icons.menu, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
