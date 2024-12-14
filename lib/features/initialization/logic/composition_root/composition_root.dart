import 'package:logger/logger.dart';
import 'package:youtube/core/utils/analytics/analytics_reporter.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/utils/shared_preferences_helper.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/analytics_reporter_factory.dart';
import 'package:youtube/features/initialization/logic/composition_root/factories/db_floor_factory.dart';
import 'package:youtube/features/initialization/models/dependency_container.dart';

final class CompositionRoot extends AsyncFactory<CompositionResult> {
  final Logger _logger;

  CompositionRoot({required Logger logger}) : _logger = logger;

  @override
  Future<CompositionResult> create() async {
    final depContainer = await DependencyContainerFactory(
      logger: _logger,
    ).create();

    return CompositionResult(depContainer);
  }
}

final class CompositionResult {
  final DependencyContainer dependencyContainer;

  CompositionResult(this.dependencyContainer);
}

final class DependencyContainerFactory extends AsyncFactory<DependencyContainer> {
  DependencyContainerFactory({required Logger logger}) : _logger = logger;

  final Logger _logger;

  @override
  Future<DependencyContainer> create() async {
    final dbFloor = await DbFloorFactory().create();

    final AnalyticsReporter analyticsReporter = AnalyticsReporterFactory(logger: _logger).create();

    final sharedPreferencesHelper = SharedPreferencesHelper();

    await sharedPreferencesHelper.initPreferences();

    final hiveDatabase = HiveDatabase();
    await hiveDatabase.initHive();

    final HiveDatabaseHelper hiveDatabaseHelper = HiveDatabaseHelper(
      database: hiveDatabase,
    );

    final storagePermissions = Permissions();

    final youtubeDataApi = YoutubeDataApi();

    return DependencyContainer(
      logger: _logger,
      dbFloor: dbFloor,
      analyticsReporter: analyticsReporter,
      sharedPreferencesHelper: sharedPreferencesHelper,
      hiveDatabaseHelper: hiveDatabaseHelper,
      storagePermissions: storagePermissions,
      youtubeDataApi: youtubeDataApi,
    );
  }
}

abstract interface class Factory<T> {
  T create();
}

abstract interface class AsyncFactory<T> {
  Future<T> create();
}
