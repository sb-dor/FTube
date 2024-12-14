import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_builder.dart';
import 'analytics_event.dart';
import 'analytics_interceptor.dart';

abstract base class AnalyticsReporter {
  final List<AnalyticsInterceptor> _interceptors;

  AnalyticsReporter({List<AnalyticsInterceptor> interceptors = const []})
      : _interceptors = interceptors;

  //
  Future<void> report(AnalyticsEvent event) async {
    final builder = AnalyticsBuilder();

    event.buildProperties(builder);

    await _report(event.name, builder.toJson());

    for (final each in _interceptors) {
      await each.print(event: event, data: builder.toJson());
    }
  }

  Future<void> _report(String eventName, Map<String, Object> parameters);
}

final class FirebaseAnalyticsReporter extends AnalyticsReporter {
  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsReporter({
    required FirebaseAnalytics analytics,
    super.interceptors,
  }) : _analytics = analytics;

  @override
  Future<void> _report(String eventName, Map<String, Object> parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
}
