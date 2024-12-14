import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/analytics/analytics_reporter.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/utils/shared_preferences_helper.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';

@immutable
final class DependencyContainer {
  final Logger logger;
  final DbFloor dbFloor;
  final AnalyticsReporter analyticsReporter;

  final SharedPreferencesHelper sharedPreferencesHelper;
  final HiveDatabaseHelper hiveDatabaseHelper;


  final Permissions storagePermissions;
  final YoutubeDataApi youtubeDataApi;

  const DependencyContainer({
    required this.logger,
    required this.dbFloor,
    required this.analyticsReporter,
    required this.sharedPreferencesHelper,
    required this.hiveDatabaseHelper,
    required this.storagePermissions,
    required this.youtubeDataApi,
  });
}
