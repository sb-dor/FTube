import 'package:flutter/material.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/widgets/shimmer_container.dart';

class HistoryInnerScreenLoadingWidget extends StatelessWidget {
  const HistoryInnerScreenLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Constants.kListViewLength,
      itemBuilder: (context, index) {
        return const _Widget();
      },
    );
  }
}

class _Widget extends StatelessWidget {
  const _Widget();

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2.1,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const ShimmerContainer(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 13,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 5),
                ShimmerContainer(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 13,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 5),
                ShimmerContainer(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 5),
                ShimmerContainer(
                  width: MediaQuery.of(context).size.width / 3,
                  height: 10,
                  borderRadius: BorderRadius.circular(10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
