import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_loaded_widget.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_loading_widget.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'widgets/trends_categories_widget/trending_screen_categories_error_widget.dart';
import 'widgets/trends_categories_widget/trending_screen_categories_loaded_widget.dart';
import 'widgets/trends_categories_widget/trentding_screen_categories_loading_widget.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        context.read<TrendingScreenBloc>().add(PaginateTrendingScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final videoCategoryState = context.watch<MainVideoCategoryCubit>().state;
      final trendsVideosState = context.watch<TrendingScreenBloc>().state;
      return Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: Colors.red,
              onRefresh: () async => context.read<TrendingScreenBloc>().add(
                  RefreshTrendingScreen(category: trendsVideosState.trendingStateModel.category)),
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.reverse) {
                    context.read<HomePageBottomNavbarCubit>().hideBottomNavbar();
                  } else if (notification.direction == ScrollDirection.forward) {
                    context.read<HomePageBottomNavbarCubit>().showBottomNavbar();
                  }
                  return true;
                },
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  children: [
                    if (videoCategoryState is LoadingVideoCategoryState)
                      const TrendingScreenCategoriesLoadingWidget()
                    else if (videoCategoryState is ErrorVideoCategoryState)
                      const TrendingScreenCategoriesErrorWidget()
                    else
                      const TrendingScreenCategoriesLoadedWidget(),
                    const SizedBox(height: 10),
                    if (trendsVideosState is LoadingTrendingScreenState)
                      const VideosLoadingWidget()
                    else if (trendsVideosState is ErrorTrendingScreenState)
                      TextWidget(text: trendsVideosState.message)
                    else
                      VideosLoadedWidget(
                        videoList: trendsVideosState.trendingStateModel.videos,
                      ),
                    if (trendsVideosState is LoadedTrendingScreenState &&
                        trendsVideosState.trendingStateModel.hasMore)
                      const Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))),
                    const SizedBox(height: 15)
                  ],
                ),
              ),
            ),
          )
        ],
      );
    });
  }
}
