import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/features/home_screen/presentation/bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'package:youtube/features/home_screen/presentation/bloc/main_home_screen_bloc.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_inner_screen_bloc/playlist_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/main_screen_overlay_info_feature_cubit.dart';
import 'package:youtube/features/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/features/search_screen/bloc/main_search_screen_bloc.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';

class BlocDependencyContainer extends StatelessWidget {
  final Widget child;

  const BlocDependencyContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomePageBottomNavbarCubit()),
        BlocProvider(create: (_) => locator<MainHomeScreenBloc>()),
        BlocProvider(create: (_) => MainAuthBloc()),
        BlocProvider(create: (_) => MainVideoCategoryCubit()),
        BlocProvider(create: (_) => HomeScreenVideosCubit()),
        BlocProvider(create: (_) => MainScreenOverlayInfoFeatureCubit()),

        // showing video popup cubits:
        BlocProvider(create: (_) => locator<YoutubeVideoCubit>()),
        BlocProvider(create: (_) => VideoInformationCubit()),
        BlocProvider(create: (_) => VideoDownloadingCubit()),
        BlocProvider(create: (_) => AudioDownloadingCubit()),
        BlocProvider(create: (_) => SimilarVideosCubit()),

        //search screen cubits:
        BlocProvider(create: (_) => MainSearchScreenBloc()),
        BlocProvider(create: (_) => SearchBodyCubit()),
        //

        // library screen bloc
        BlocProvider(create: (_) => locator<HistoryBloc>()),
        BlocProvider(create: (_) => locator<PlaylistsBloc>()),
        BlocProvider(create: (_) => locator<LibraryDownloadsBloc>()),

        // library inner screens bloc
        BlocProvider(create: (_) => locator<HistoryInnerScreenBloc>()),
        BlocProvider(create: (_) => locator<PlaylistInnerScreenBloc>()),
        BlocProvider(create: (_) => locator<PlaylistVideosInnerScreenBloc>()),

        BlocProvider<TrendingScreenBloc>(
          create: (_) => locator<TrendingScreenBloc>(),
        ),
        //
        BlocProvider<TopOverlayFeatureBloc>(
          create: (_) => TopOverlayFeatureBloc(),
        ),
        //
      ],
      child: child,
    );
  }
}
