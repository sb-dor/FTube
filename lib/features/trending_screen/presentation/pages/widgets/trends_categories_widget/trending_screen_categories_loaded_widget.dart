import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/features/trending_screen/bloc/trending_screen_bloc.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class TrendingScreenCategoriesLoadedWidget extends StatelessWidget {
  const TrendingScreenCategoriesLoadedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final trendsVideosState = context.watch<TrendingScreenBloc>().state;

        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.only(left: 10, right: 10),
            separatorBuilder: (context, index) => const SizedBox(width: 15),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: VideoCategory.trendsCategories.length,
            itemBuilder: (context, index) {
              final category = VideoCategory.trendsCategories[index];
              return InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap:
                    () => context.read<TrendingScreenBloc>().add(
                      RefreshTrendingScreen(category: category, refresh: true),
                    ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 10,
                    top: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        trendsVideosState.trendingStateModel.category.id ==
                                category.id
                            ? Colors.red
                            : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Center(
                    child: TextWidget(
                      text: category.kind ?? '-',
                      size: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.9,
                      color:
                          trendsVideosState.trendingStateModel.category.id ==
                                  category.id
                              ? Colors.white
                              : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
