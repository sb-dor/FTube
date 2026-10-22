import 'package:flutter/material.dart';
import 'package:youtube/src/common/widget/shimmer_box.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';

/// Shimmering placeholder in the shape of a [VideoCardWidget].
class VideoCardLoadingWidget extends StatelessWidget {
  const VideoCardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(
          height: VideoCardWidget.thumbnailHeight,
          width: width,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ShimmerBox(width: 50, height: 50, borderRadius: BorderRadius.circular(50)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: width, height: 15, borderRadius: BorderRadius.circular(10)),
                  const SizedBox(height: 10),
                  ShimmerBox(width: width / 2, height: 15, borderRadius: BorderRadius.circular(10)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A non-scrolling column of [count] card placeholders.
class VideoListLoadingWidget extends StatelessWidget {
  const VideoListLoadingWidget({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < count; i++) ...[
        const VideoCardLoadingWidget(),
        const SizedBox(height: 30),
      ],
    ],
  );
}
