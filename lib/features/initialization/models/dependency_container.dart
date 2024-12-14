import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/analytics/analytics_reporter.dart';

@immutable
final class DependencyContainer {
  final Logger logger;
  final DbFloor dbFloor;
  final AnalyticsReporter analyticsReporter;

  const DependencyContainer({
    required this.logger,
    required this.dbFloor,
    required this.analyticsReporter,
  });
}
