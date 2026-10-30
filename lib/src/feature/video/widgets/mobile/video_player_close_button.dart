import 'package:flutter/material.dart';

/// The "close" chevron in the top-left corner of the player; place it in a [Stack].
class VideoPlayerCloseButton extends StatelessWidget {
  const VideoPlayerCloseButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 4,
    left: 4,
    child: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
    ),
  );
}
