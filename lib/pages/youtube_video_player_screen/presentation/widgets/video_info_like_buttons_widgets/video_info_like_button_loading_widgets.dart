import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube/widgets/shimmer_container.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoInfoLikeButtonLoadingWidgets extends StatelessWidget {
  const VideoInfoLikeButtonLoadingWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerContainer(width: 30, height: 30, borderRadius: BorderRadius.circular(50)),
                const SizedBox(height: 5),
                ShimmerContainer(width: 40, height: 10, borderRadius: BorderRadius.circular(10)),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerContainer(width: 30, height: 30, borderRadius: BorderRadius.circular(50)),
                const SizedBox(height: 5),
                ShimmerContainer(width: 40, height: 10, borderRadius: BorderRadius.circular(10)),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerContainer(width: 30, height: 30, borderRadius: BorderRadius.circular(50)),
                const SizedBox(height: 5),
                ShimmerContainer(width: 40, height: 10, borderRadius: BorderRadius.circular(10)),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerContainer(width: 30, height: 30, borderRadius: BorderRadius.circular(50)),
                const SizedBox(height: 5),
                ShimmerContainer(width: 40, height: 10, borderRadius: BorderRadius.circular(10)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
