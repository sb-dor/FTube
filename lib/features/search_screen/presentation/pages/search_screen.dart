import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/widgets/videos_widgets/videos_error_widget.dart';
import 'package:youtube/core/widgets/videos_widgets/videos_loaded_widget.dart';
import 'package:youtube/core/widgets/videos_widgets/videos_loading_widget.dart';
import 'package:youtube/features/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/features/search_screen/bloc/cubits/search_body_cubit/search_body_states.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/search_screen/bloc/search_screen_events.dart';
import 'animated_search_bar/animated_search_bar.dart';
import 'layouts/searching_body_sreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  SearchScreenEventFunctionsHolder searchFunc() =>
      SearchScreenEventFunctionsHolder(
        searchingBodyStateFunc: () {
          context.read<SearchBodyCubit>().searchingBodyState();
        },
        errorSearchBodyStateFunc: () {
          context.read<SearchBodyCubit>().errorSearchBodyState();
        },
        emitStateFunc: () {
          context.read<SearchBodyCubit>().emitState();
        },
        loadedSearchBodyStateFunc: () {
          context.read<SearchBodyCubit>().loadedSearchBodyState();
        },
        loadingSearchBodyStateFunc: () {
          context.read<SearchBodyCubit>().loadingSearchBodyState();
        },
      );

  final GlobalContextHelper _globalContextHelper = GlobalContextHelper.instance;
  late AnimationController _searchBarAnimationController;
  late Animation<double> _searchBarAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MainSearchScreenBloc>().add(
      InitSearchScreenEvent(
        searchingBodyStateFunc: () => searchFunc().searchingBodyStateFunc(),
      ),
    );
    context.read<MainSearchScreenBloc>().add(StartCheckingPaginatingTimer());
    _searchBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _searchBarAnimation = Tween<double>(begin: 0.200, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchBarAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );
    _searchBarAnimationController.forward();
    _searchBarAnimationController.addListener(() {
      if (_searchBarAnimationController.isCompleted) {
        context.read<MainSearchScreenBloc>().add(RequestToTextField());
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.offset) {
        final isLoadedSearchBodyState =
            BlocProvider.of<SearchBodyCubit>(context).state
                is LoadedSearchBodyState;
        context.read<MainSearchScreenBloc>().add(
          PaginateSearchScreenEvent(
            functionsHolder: searchFunc(),
            isLoadedSearchBodyState: isLoadedSearchBodyState,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _searchBarAnimationController.dispose();
    _globalContextHelper.globalNavigatorContext.currentContext!
        .read<MainSearchScreenBloc>()
        .add(StartCheckingPaginatingTimer(close: true));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final searchBodyCubit = context.watch<SearchBodyCubit>();
        final mainSearchScreenCubit =
            context.watch<MainSearchScreenBloc>().state;

        // data
        final mainSearchScreenStateModel =
            mainSearchScreenCubit.searchScreenStateModel;
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: AnimatedSearchBar(
              searchBarAnimationController: _searchBarAnimationController,
              searchBarAnimation: _searchBarAnimation,
              scrollController: _scrollController,
              functionsHolder: searchFunc(),
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
              onRefresh:
                  () async => context.read<MainSearchScreenBloc>().add(
                    ClickSearchButtonEvent(functionsHolder: searchFunc()),
                  ),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 10, right: 10),
                children: [
                  if (searchBodyCubit.state is SearchingBodyState)
                    if (mainSearchScreenStateModel.suggestData.isNotEmpty)
                      SearchingBodyScreen(
                        suggests: mainSearchScreenStateModel.suggestData,
                        functionsHolder: searchFunc(),
                      )
                    else
                      SearchingBodyScreen(
                        suggests: mainSearchScreenStateModel.searchData,
                        showDeleteButton: true,
                        functionsHolder: searchFunc(),
                      )
                  else if (searchBodyCubit.state is LoadingSearchBodyState)
                    const VideosLoadingWidget()
                  else if (searchBodyCubit.state is ErrorSearchBodyState)
                    VideosErrorWidget(
                      onTap:
                          () => context.read<MainSearchScreenBloc>().add(
                            ClickSearchButtonEvent(
                              functionsHolder: searchFunc(),
                            ),
                          ),
                    )
                  else
                    VideosLoadedWidget(
                      videoList: mainSearchScreenStateModel.videos,
                      parentContext: context,
                    ),
                  if (mainSearchScreenStateModel.hasMore &&
                      searchBodyCubit.state is LoadedSearchBodyState)
                    const Column(
                      children: [
                        SizedBox(height: 20),
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
