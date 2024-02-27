import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube/widgets/shimmer_container.dart';

class LoadingHistoryWidget extends StatelessWidget {
  const LoadingHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        const SizedBox(height: 15),
        SizedBox(
          height: 210,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: 15,
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
  const _Widget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 130,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const ShimmerContainer(),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 5),
                    ShimmerContainer(
                      height: 15,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 10),
                    ShimmerContainer(
                      height: 15,
                      borderRadius: BorderRadius.circular(10),
                    )
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        ShimmerContainer(
                          height: 20,
                          width: 20,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(width: 10),
                        ShimmerContainer(
                          height: 15,
                          width: 50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
