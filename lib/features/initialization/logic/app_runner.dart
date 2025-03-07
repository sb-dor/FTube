import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/app_logger_factory.dart';
import 'package:youtube/features/initialization/view/app.dart';
import 'package:youtube/features/initialization/view/bloc_dependency_container.dart';
import 'package:youtube/firebase_options.dart';

class AppRunner {
  Future<void> init() async {
    runZonedGuarded(
      () async {
        final binding = WidgetsFlutterBinding.ensureInitialized();

        binding.deferFirstFrame();

        Future<void> initSettings() async {
          try {
            await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            );

            FlutterError.onError = (errorDetails) {
              FirebaseCrashlytics.instance.recordFlutterFatalError(
                errorDetails,
              );
            };

            // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
            PlatformDispatcher.instance.onError = (error, stack) {
              FirebaseCrashlytics.instance.recordError(
                error,
                stack,
                fatal: true,
              );
              return true;
            };

            await APISettings.initDio();

            final appLogger =
                AppLoggerFactory(
                  logFilter: kDebugMode ? DevelopmentFilter() : NoOpLogFilter(),
                ).create();

            final compositionResults =
                await CompositionRoot(logger: appLogger).create();

            runApp(
              BlocDependencyContainer(
                compositionResult: compositionResults,
                child: const MainApp(),
              ),
            );
          } catch (e, sTrace) {
            FirebaseCrashlytics.instance.recordError(e, sTrace, fatal: true);
          } finally {
            binding.allowFirstFrame();
          }
        }

        await initSettings();
      },
      (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace);
      },
    );
  }
}
