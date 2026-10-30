import 'package:flutter/material.dart';
import 'package:youtube/src/common/widget/shimmer_box.dart';

/// Shimmering placeholders in the shape of video rows (history, playlist videos).
class VideoRowLoadingWidget extends StatelessWidget {
  const VideoRowLoadingWidget({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                  width: width / 2.1,
                  height: 110,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 15, borderRadius: BorderRadius.circular(10)),
                      const SizedBox(height: 10),
                      ShimmerBox(
                        width: width / 4,
                        height: 12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
