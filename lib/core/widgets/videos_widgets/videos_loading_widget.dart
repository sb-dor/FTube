import 'package:flutter/material.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/widgets/shimmer_container.dart';

class VideosLoadingWidget extends StatelessWidget {
  const VideosLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 30),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: Constants.perPage,
        itemBuilder: (context, index) {
          return Column(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ShimmerContainer(height: 180, width: MediaQuery.of(context).size.width),
            ),
            const SizedBox(height: 5),
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ShimmerContainer(width: 50, height: 50, borderRadius: BorderRadius.circular(50)),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      ShimmerContainer(
                          width: MediaQuery.of(context).size.width,
                          height: 15,
                          borderRadius: BorderRadius.circular(10)),
                      const SizedBox(height: 10),
                      ShimmerContainer(
                          width: MediaQuery.of(context).size.width / 2,
                          height: 15,
                          borderRadius: BorderRadius.circular(10))
                    ]))
              ]),
            )
          ]);
        });
  }
}
