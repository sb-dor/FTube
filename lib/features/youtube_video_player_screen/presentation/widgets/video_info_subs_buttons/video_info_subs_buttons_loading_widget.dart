import 'package:flutter/material.dart';
import 'package:youtube/core/widgets/shimmer_container.dart';

class VideoInfoSubsButtonsLoadingWidget extends StatelessWidget {
  const VideoInfoSubsButtonsLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerContainer(
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 15),
          ShimmerContainer(
            width: 115,
            height: 40,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
