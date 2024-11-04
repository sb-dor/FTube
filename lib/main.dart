
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/app_routes.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/x_injection_containers/injection_container.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_inner_screen_bloc/playlist_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/main_screen_overlay_info_feature/presentation/cubit/main_screen_overlay_info_feature_cubit.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/top_overlay_feature/view/pages/top_overlay_feature.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/firebase_options.dart';
import 'core/utils/hive_database_helper/hive_database.dart';
import 'core/utils/shared_preferences_helper.dart';
import 'features/home_screen/bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'features/home_screen/bloc/main_home_screen_bloc.dart';
import 'features/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'features/search_screen/bloc/main_search_screen_bloc.dart';
import 'features/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'features/youtube_video_player_screen/cubit/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TopOverlayFeatureBloc>(
          create: (_) => TopOverlayFeatureBloc(),
        )
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TopOverlayFeature(),
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initGetIt();
  await locator<SharedPreferencesHelper>().initPreferences();
  await APISettings.initDio();
  await locator<HiveDatabase>().initHive();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
// Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomePageBottomNavbarCubit()),
        BlocProvider(create: (_) => MainHomeScreenBloc()),
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
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // context.read<MainAuthBloc>().add(CheckAuthEvent(authorizationService: GoogleService()));
    context.read<MainScreenOverlayInfoFeatureCubit>().checkCanUserScroll();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: const TextScaler.linear(1.0)),
      child: MaterialApp.router(
        scaffoldMessengerKey:
            locator<GlobalContextHelper>().globalNavigatorContext,
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        routerConfig: goRouter,
      ),
    );
  }
}
