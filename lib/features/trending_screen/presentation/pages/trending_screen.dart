import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';

import '../widgets/home_screen_categories_widgets/trending_screen_trends_error_widget.dart';
import '../widgets/home_screen_categories_widgets/trending_screen_trends_loaded_widget.dart';
import '../widgets/home_screen_categories_widgets/trentding_screen_trends_loading_widget.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final videoCategoryState = context.watch<MainVideoCategoryCubit>().state;
      return Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (videoCategoryState is LoadingVideoCategoryState)
                  const TrendingScreenTrendsLoadingWidget()
                else if (videoCategoryState is ErrorVideoCategoryState)
                  const TrendingScreenTrendsErrorWidget()
                else
                  const TrendingScreenTrendsLoadedWidget(),
              ],
            ),
          )
        ],
      );
    });
  }
}
