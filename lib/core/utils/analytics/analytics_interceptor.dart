import 'package:logger/logger.dart';

import 'analytics_event.dart';

abstract interface class AnalyticsInterceptor {
  Future<void> print({required AnalyticsEvent event, required Map<String, Object> data});
}

final class LoggingAnalyticsInterceptor implements AnalyticsInterceptor {
  final Logger _logger;

  LoggingAnalyticsInterceptor(this._logger);

  @override
  Future<void> print({required AnalyticsEvent event, required Map<String, Object> data}) async {
    _logger.log(Level.debug, "Reported: ${event.name} | Data: $data");
  }
}
