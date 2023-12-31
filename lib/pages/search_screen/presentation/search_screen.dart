import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/pages/search_screen/bloc/cubits/search_body_cubit/search_body_states.dart';
import 'package:youtube/pages/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/pages/search_screen/bloc/search_screen_events.dart';
import 'package:youtube/pages/search_screen/presentation/animated_search_bar/animated_search_bar.dart';
import 'package:youtube/pages/search_screen/presentation/layouts/searching_body_sreen.dart';
import 'package:youtube/pages/widgets/videos_widgets/videos_error_widget.dart';
import 'package:youtube/pages/widgets/videos_widgets/videos_loaded_widget.dart';
import 'package:youtube/pages/widgets/videos_widgets/videos_loading_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _searchBarAnimationController;
  late Animation<double> _searchBarAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MainSearchScreenBloc>().add(InitSearchScreenEvent(context: context));
    _searchBarAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _searchBarAnimation = Tween<double>(begin: 0.200, end: 1.0).animate(
        CurvedAnimation(parent: _searchBarAnimationController, curve: Curves.easeInOutCubic));
    _searchBarAnimationController.forward();
    _searchBarAnimationController.addListener(() {
      if (_searchBarAnimationController.isCompleted) {
        context.read<MainSearchScreenBloc>().add(RequestToTextField());
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        context.read<MainSearchScreenBloc>().add(PaginateSearchScreenEvent(context: context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final searchBodyCubit = context.watch<SearchBodyCubit>();
      final mainSearchScreenCubit = context.watch<MainSearchScreenBloc>().state;

      // data
      var mainSearchScreenStateModel = mainSearchScreenCubit.searchScreenStateModel;
      return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          leading: AnimatedSearchBar(
            searchBarAnimationController: _searchBarAnimationController,
            searchBarAnimation: _searchBarAnimation,
            scrollController: _scrollController,
          ),
          leadingWidth: MediaQuery.of(context).size.width,
        ),
        body: GestureDetector(
          onTap: () {
            if (searchBodyCubit.state is SearchingBodyState) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: RefreshIndicator(
            color: Colors.red,
            onRefresh: () async =>
                context.read<MainSearchScreenBloc>().add(ClickSearchButtonEvent(context: context)),
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(left: 10, right: 10),
              children: [
                if (searchBodyCubit.state is SearchingBodyState)
                  const SearchingBodyScreen()
                else if (searchBodyCubit.state is LoadingSearchBodyState)
                  const VideosLoadingWidget()
                else if (searchBodyCubit.state is ErrorSearchBodyState)
                  const VideosErrorWidget()
                else
                  VideosLoadedWidget(videoList: mainSearchScreenStateModel.videos),
                if (mainSearchScreenStateModel.hasMore &&
                    searchBodyCubit.state is LoadedSearchBodyState)
                  const Column(
                    children: [
                      SizedBox(height: 20),
                      SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)),
                    ],
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      );
    });
  }
}
