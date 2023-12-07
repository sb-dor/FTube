import 'package:flutter/material.dart';

class VideoSettingsButton extends StatelessWidget {
  const VideoSettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      child: IconButton(
        onPressed: () => [],
        icon: Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
      ),
    );
  }
}
