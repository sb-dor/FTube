import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/features/home_screen/bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'package:youtube/features/home_screen/bloc/cubits/home_screen_videos_cubit/home_screen_videos_states.dart';
import 'package:youtube/features/home_screen/bloc/home_screen_bloc_events.dart';
import 'package:youtube/features/home_screen/bloc/main_home_screen_bloc.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_error_widget.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_loaded_widget.dart';
import 'package:youtube/features/widgets/videos_widgets/videos_loading_widget.dart';
import 'widgets/home_screen_categories_widgets/home_screen_categories_error_widget.dart';
import 'widgets/home_screen_categories_widgets/home_screen_categories_loaded_widget.dart';
import 'widgets/home_screen_categories_widgets/home_screen_categories_loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    context
        .read<MainHomeScreenBloc>()
        .add(RefreshHomeScreenEvent(context: context, refresh: false));

    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        debugPrint("last");
        context.read<MainHomeScreenBloc>().add(PaginateHomeScreenEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final mainHomeScreenState = context.watch<MainHomeScreenBloc>().state;
      final videoCategoryState = context.watch<MainVideoCategoryCubit>().state;
      final homeScreenVideosState = context.watch<HomeScreenVideosCubit>().state;

      //data
      var mainHomeScreenStateModel = mainHomeScreenState.homeScreenStateModel;

      return Column(
        children: [
          if (videoCategoryState is LoadingVideoCategoryState)
            const HomeScreenCategoriesLoadingWidget()
          else if (videoCategoryState is ErrorVideoCategoryState)
            const HomeScreenCategoriesErrorWidget()
          else
            HomeScreenSelectTypeContentLoadedWidget(scrollController: _scrollController),
          const SizedBox(height: 10),
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  context.read<HomePageBottomNavbarCubit>().showBottomNavbar();
                } else if (notification.direction == ScrollDirection.reverse) {
                  context.read<HomePageBottomNavbarCubit>().hideBottomNavbar();
                }
                return true;
              },
              child: RefreshIndicator(
                color: Colors.red,
                onRefresh: () async =>   context.read<MainHomeScreenBloc>().add(RefreshHomeScreenEvent(context: context,refresh: true)),
                child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    children: [
                      //
                      if (homeScreenVideosState is LoadingHomeScreenVideosState)
                        const VideosLoadingWidget()
                      else if (homeScreenVideosState is ErrorHomeScreenVideosState)
                        const VideosErrorWidget()
                      else
                        VideosLoadedWidget(videoList: mainHomeScreenStateModel.videos),
                      const SizedBox(height: 5),
                      if (homeScreenVideosState is LoadedHomeScreenVideosState &&
                          mainHomeScreenStateModel.hasMore)
                        const Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(color: Colors.red, strokeWidth: 2))),
                      const SizedBox(height: 15)
                    ]),
              ),
            ),
          ),
        ],
      );
    });
  }
}
