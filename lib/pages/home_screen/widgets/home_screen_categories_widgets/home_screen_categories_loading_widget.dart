import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube/widgets/shimmer_container.dart';
import 'package:youtube/widgets/text_widget.dart';

class HomeScreenCategoriesLoadingWidget extends StatelessWidget {
  const HomeScreenCategoriesLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 35,
        child: ListView.separated(
            padding: EdgeInsets.only(left: 10, right: 10),
            separatorBuilder: (context, index) => SizedBox(width: 15),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return ShimmerContainer(
                width: 100,
                borderRadius: BorderRadius.circular(15),
              );
            }));
  }
}
