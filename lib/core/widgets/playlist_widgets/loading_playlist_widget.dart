import 'package:flutter/material.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/widgets/shimmer_container.dart';

class LoadingPlaylistWidget extends StatelessWidget {
  final bool listView;
  final bool gridView;

  const LoadingPlaylistWidget({
    super.key,
    this.listView = true,
    this.gridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!gridView) const SizedBox(height: 30),
        if (!gridView)
          Row(
            children: [
              Expanded(
                child: ShimmerContainer(
                  height: 20,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 30),
              ShimmerContainer(
                width: 100,
                height: 50,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        if (!gridView) const SizedBox(height: 15),
        if (gridView)
          GridView.builder(
            shrinkWrap: true,
            itemCount: Constants.kGridViewLength,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) => const _Widget(),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemCount: Constants.kListViewLength,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return const _Widget();
              },
            ),
          ),
      ],
    );
  }
}

class _Widget extends StatelessWidget {
  const _Widget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 130,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 15,
                left: 15,
                bottom: 0,
                child: ShimmerContainer(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Positioned(
                top: 5,
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 5,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ShimmerContainer(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ShimmerContainer(
            width: 110,
            borderRadius: BorderRadius.circular(10),
            height: 15,
          ),
        ),
      ],
    );
  }
}
