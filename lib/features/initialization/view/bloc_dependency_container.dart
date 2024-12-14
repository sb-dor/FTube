import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/features/home_screen/presentation/bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'package:youtube/features/home_screen/presentation/bloc/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/history_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/history_inner_screen_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/home_screen_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/library_downloads_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/playlist_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/playlist_inner_screen_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/playlist_videos_inner_screen_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/search_screen_bloc_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/trending_screen_bloc_factory.dart';
import 'package:youtube/features/initialization/models/dependency_container.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/main_screen_overlay_info_feature_cubit.dart';
import 'package:youtube/features/search_screen/presentation/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';

class BlocDependencyContainer extends StatelessWidget {
  final CompositionResult compositionResult;
  final Widget child;

  const BlocDependencyContainer({
    super.key,
    required this.compositionResult,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomePageBottomNavbarCubit()),
        BlocProvider(create: (_) => HomeScreenBlocFactory().create()),
        BlocProvider(create: (_) => MainAuthBloc()),
        BlocProvider(create: (_) => MainVideoCategoryCubit()),
        BlocProvider(create: (_) => HomeScreenVideosCubit()),
        BlocProvider(
            create: (_) => MainScreenOverlayInfoFeatureCubit(
                  compositionResult.dependencyContainer.hiveDatabaseHelper,
                )),

        // showing video popup cubits:
        BlocProvider(
          create: (_) => YoutubeVideoCubit(
            dbFloor: compositionResult.dependencyContainer.dbFloor,
            youtubeDataApi: compositionResult.dependencyContainer.youtubeDataApi,
            permission: compositionResult.dependencyContainer.storagePermissions,
          ),
        ),
        BlocProvider(create: (_) => VideoInformationCubit()),
        BlocProvider(create: (_) => VideoDownloadingCubit()),
        BlocProvider(create: (_) => AudioDownloadingCubit()),
        BlocProvider(create: (_) => SimilarVideosCubit()),

        //search screen cubits:
        BlocProvider(
            create: (_) => SearchScreenBlocFactory(
                  compositionResult.dependencyContainer.youtubeDataApi,
                  compositionResult.dependencyContainer.hiveDatabaseHelper,
                ).create()),
        BlocProvider(create: (_) => SearchBodyCubit()),
        //

        // library screen bloc
        BlocProvider(
            create: (_) => HistoryBlocFactory(
                  compositionResult.dependencyContainer.dbFloor,
                ).create()),
        BlocProvider(
            create: (_) => PlaylistBlocFactory(
                  compositionResult.dependencyContainer.dbFloor,
                ).create()),
        BlocProvider(
          create: (_) => LibraryDownloadsBlocFactory(
            compositionResult.dependencyContainer.dbFloor,
          ).create(),
        ),

        // library inner screens bloc
        BlocProvider(
            create: (_) => HistoryInnerScreenBlocFactory(
                  compositionResult.dependencyContainer.dbFloor,
                ).create()),
        BlocProvider(
            create: (_) => PlaylistInnerScreenBlocFactory(
                  compositionResult.dependencyContainer.dbFloor,
                ).create()),
        BlocProvider(
            create: (_) => PlaylistVideosInnerScreenBlocFactory(
                  compositionResult.dependencyContainer.dbFloor,
                ).create()),

        BlocProvider<TrendingScreenBloc>(
          create: (_) => TrendingScreenBlocFactory(
            youtubeDataApi: compositionResult.dependencyContainer.youtubeDataApi,
          ).create(),
        ),
        //
        BlocProvider<TopOverlayFeatureBloc>(
          create: (_) => TopOverlayFeatureBloc(),
        ),
        //
      ],
      child: Provider<DependencyContainer>(
        create: (_) => compositionResult.dependencyContainer,
        child: child,
      ),
    );
  }
}
