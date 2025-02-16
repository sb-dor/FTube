import 'package:flutter/material.dart';
import 'package:youtube/core/widgets/shimmer_container.dart';

class HomeScreenCategoriesLoadingWidget extends StatelessWidget {
  const HomeScreenCategoriesLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 10, right: 10),
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        itemBuilder: (context, index) {
          return ShimmerContainer(
            width: 100,
            borderRadius: BorderRadius.circular(15),
          );
        },
      ),
    );
  }
}
