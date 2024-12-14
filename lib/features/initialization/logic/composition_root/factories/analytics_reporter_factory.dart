import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';
import 'package:youtube/core/utils/analytics/analytics_interceptor.dart';
import 'package:youtube/core/utils/analytics/analytics_reporter.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';

final class AnalyticsReporterFactory implements Factory<AnalyticsReporter> {
  //
  AnalyticsReporterFactory({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  AnalyticsReporter create() {
    final AnalyticsReporter reporter = FirebaseAnalyticsReporter(
      analytics: FirebaseAnalytics.instance,
      interceptors: [
        LoggingAnalyticsInterceptor(_logger),
      ],
    );

    return reporter;
  }
}
