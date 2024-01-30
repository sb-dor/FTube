import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/app_routes.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/auth_bloc_events.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/authorization_service/google_service/google_service.dart';
import 'package:youtube/core/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/core/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/core/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/features/home_screen/bloc/home_screen_bloc_events.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/firebase_options.dart';
import 'package:youtube/injection_container.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/utils/shared_preferences_helper.dart';
import 'features/home_screen/bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'features/home_screen/bloc/main_home_screen_bloc.dart';
import 'features/search_screen/bloc/cubits/search_body_cubit/search_body_cubit.dart';
import 'features/search_screen/bloc/main_search_screen_bloc.dart';
import 'features/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'features/youtube_video_player_screen/cubit/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initGetIt();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesHelper.instance.initPreferences();
  await APISettings.initDio();
  await HiveDatabase.instance.initHive();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
// Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MultiBlocProvider(providers: [
    BlocProvider(create: (_) => HomePageBottomNavbarCubit()),
    BlocProvider(create: (_) => MainHomeScreenBloc()),
    BlocProvider(create: (_) => MainAuthBloc()),
    BlocProvider(create: (_) => MainVideoCategoryCubit()),
    BlocProvider(create: (_) => HomeScreenVideosCubit()),

    // showing video popup cubits:
    BlocProvider(create: (_) => YoutubeVideoCubit()),
    BlocProvider(create: (_) => VideoInformationCubit()),
    BlocProvider(create: (_) => VideoDownloadingCubit()),
    BlocProvider(create: (_) => AudioDownloadingCubit()),
    BlocProvider(create: (_) => SimilarVideosCubit()),

    //search screen cubits:
    BlocProvider(create: (_) => MainSearchScreenBloc()),
    BlocProvider(create: (_) => SearchBodyCubit()),
    //
    BlocProvider<TrendingScreenBloc>(
      create: (_) => locator<TrendingScreenBloc>(),
    ),
    //
  ], child: const MainApp()));
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
    context.read<MainHomeScreenBloc>().add(RefreshHomeScreenEvent(context: context));
    context
        .read<TrendingScreenBloc>()
        .add(RefreshTrendingScreen(category: VideoCategory.trendsCategories.first));
    context.read<MainAuthBloc>().add(CheckAuthEvent(authorizationService: GoogleService()));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: MaterialApp.router(
          scaffoldMessengerKey: GlobalContextHelper.instance.globalNavigatorContext,
          theme: ThemeData(useMaterial3: true),
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
        ));
  }
}
