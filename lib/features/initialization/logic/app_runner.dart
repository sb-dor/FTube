import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/core/utils/shared_preferences_helper.dart';
import 'package:youtube/core/x_injection_containers/injection_container.dart';
import 'package:youtube/features/initialization/view/app.dart';
import 'package:youtube/features/initialization/view/bloc_dependency_container.dart';
import 'package:youtube/firebase_options.dart';

class AppRunner {
  Future<void> init() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();

    binding.deferFirstFrame();

    Future<void> initSettings() async {
      try {
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
          const BlocDependencyContainer(child: MainApp()),
        );
      } catch (e, sTrace) {
        FirebaseCrashlytics.instance.recordError(e, sTrace, fatal: true);
      } finally {
        binding.allowFirstFrame();
      }
    }

    await initSettings();
  }
}
