import 'package:flutter/material.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';

/// Round channel avatar with a thin grey border.
class ChannelAvatarWidget extends StatelessWidget {
  const ChannelAvatarWidget({required this.url, super.key, this.size = 50});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade400, width: 0.5),
    ),
    child: ClipOval(
      child: NetworkImageWidget(
        url: url,
        width: size,
        height: size,
        fallbackAsset: 'assets/custom_images/custom_user_image.png',
      ),
    ),
  );
}
