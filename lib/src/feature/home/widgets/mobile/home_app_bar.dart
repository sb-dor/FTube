import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/home/models/home_tab.dart';
import 'package:youtube/src/feature/home/widgets/home_config_widget.dart';
import 'package:youtube/src/feature/search/widgets/search_config_widget.dart';

/// App bar with a curved bottom edge: logo and title (go to Home) and a search button.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  static const double _curveDepth = 40;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + _curveDepth);

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: const _ShadowPainter(clipper: _CurvedBottomClipper(_curveDepth)),
    child: ClipPath(
      clipper: const _CurvedBottomClipper(_curveDepth),
      child: AppBar(
        scrolledUnderElevation: 0,
        title: GestureDetector(
          onTap: () => HomeConfigInhWidget.of(context).homeDataController.selectTab(HomeTab.feed),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset('assets/app_icon/app_main_icon_1024.png', width: 30, height: 30),
              ),
              const SizedBox(width: 10),
              Text(Localization.of(context).appTitle),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => SearchConfigWidget.open(context),
            icon: const Icon(CupertinoIcons.search, color: Colors.black),
          ),
        ],
      ),
    ),
  );
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  const _CurvedBottomClipper(this.depth);

  final double depth;

  @override
  Path getClip(Size size) => Path()
    ..lineTo(0, size.height - depth)
    ..quadraticBezierTo(size.width / 2, size.height, size.width, size.height - depth)
    ..lineTo(size.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant _CurvedBottomClipper oldClipper) => oldClipper.depth != depth;
}

class _ShadowPainter extends CustomPainter {
  const _ShadowPainter({required this.clipper});

  final CustomClipper<Path> clipper;

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = Shadow(color: Colors.grey.shade400, blurRadius: 5, offset: const Offset(0, 0.3));
    canvas.drawPath(clipper.getClip(size).shift(shadow.offset), shadow.toPaint());
  }

  @override
  bool shouldRepaint(covariant _ShadowPainter oldDelegate) => false;
}
