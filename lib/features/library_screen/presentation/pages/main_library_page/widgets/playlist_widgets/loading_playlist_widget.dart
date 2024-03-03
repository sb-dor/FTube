import 'package:flutter/material.dart';
import 'package:youtube/widgets/shimmer_container.dart';

class LoadingPlaylistWidget extends StatelessWidget {
  const LoadingPlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                top: 8,
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
        ShimmerContainer(
          borderRadius: BorderRadius.circular(10),
          height: 15,
        )
      ],
    );
  }
}
