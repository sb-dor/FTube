// ignore_for_file: avoid_classes_with_only_static_members

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:l/l.dart';

/// Error reporting. Errors are logged locally and, in release builds, sent to Crashlytics.
abstract final class ErrorUtil {
  static bool _enabled = false;

  /// Starts Crashlytics reporting for uncaught Flutter and platform errors.
  ///
  /// Call after Firebase is initialized.
  static void init() {
    _enabled = !kDebugMode;
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(_enabled).ignore();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (_enabled) FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      logError(error, stackTrace, code: 'PLATFORM_DISPATCHER').ignore();
      return true;
    };
  }

  /// Logs an error locally and, when enabled, reports it with its [code].
  static Future<void> logError(
    Object error,
    StackTrace stackTrace, {
    String code = 'UNCATEGORIZED',
  }) async {
    l.w('$code: $error', stackTrace);
    if (!_enabled) return;
    await FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: code);
  }
}
