import 'package:flutter/material.dart';
import 'package:youtube/widgets/shimmer_container.dart';

class VideoInformationLoadingWidget extends StatelessWidget {
  const VideoInformationLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerContainer(
          width: MediaQuery.of(context).size.width,
          height: 15,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 3),
        ShimmerContainer(
          width: MediaQuery.of(context).size.width / 2,
          height: 15,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 5),
        ShimmerContainer(
          width: MediaQuery.of(context).size.width / 5,
          height: 10,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShimmerContainer(
                width: 35,
                height: 35,
                borderRadius: BorderRadius.circular(50),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShimmerContainer(
                  height: 20,
                  width: MediaQuery.of(context).size.width / 2,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 5),
              ShimmerContainer(width: 100, height: 30, borderRadius: BorderRadius.circular(15))
            ],
          ),
        ),
      ],
    );
  }
}
