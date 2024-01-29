import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_loaded_widget.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_loading_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

import 'widgets/home_screen_categories_widgets/trending_screen_trends_error_widget.dart';
import 'widgets/home_screen_categories_widgets/trending_screen_trends_loaded_widget.dart';
import 'widgets/home_screen_categories_widgets/trentding_screen_trends_loading_widget.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final videoCategoryState = context.watch<MainVideoCategoryCubit>().state;
      final trendsVideosState = context.watch<TrendingScreenBloc>().state;
      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  context.read<TrendingScreenBloc>().add(RefreshTrendingScreen()),
              child: ListView(
                padding: const EdgeInsets.only(left: 10, right: 10),
                children: [
                  if (videoCategoryState is LoadingVideoCategoryState)
                    const TrendingScreenTrendsLoadingWidget()
                  else if (videoCategoryState is ErrorVideoCategoryState)
                    const TrendingScreenTrendsErrorWidget()
                  else
                    const TrendingScreenTrendsLoadedWidget(),
                  const SizedBox(height: 10),
                  if (trendsVideosState is LoadingTrendingScreenState)
                    const VideosLoadingWidget()
                  else if (trendsVideosState is ErrorTrendingScreenState)
                    TextWidget(text: "${trendsVideosState.message}")
                  else
                    VideosLoadedWidget(
                      videoList: trendsVideosState.trendingStateModel.videos,
                    ),
                ],
              ),
            ),
          )
        ],
      );
    });
  }
}
