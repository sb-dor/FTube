import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_home_screen/rest_api_home_screen.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/app_routes.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/auth_bloc_events.dart';
import 'package:youtube/blocs_and_cubits/auth_bloc/main_auth_bloc.dart';
import 'package:youtube/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/main_home_screen_bloc.dart';
import 'package:youtube/firebase_options.dart';
import 'package:youtube/services/authorization_service/google_service/google_service.dart';
import 'package:youtube/utils/shared_preferences_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SharedPreferencesHelper.instance.initPreferences();
  await APISettings.initDio();

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
    context.read<MainAuthBloc>().add(CheckAuthEvent(authorizationService: GoogleService()));
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes(),
          initialRoute: "/",
        ));
  }
}
