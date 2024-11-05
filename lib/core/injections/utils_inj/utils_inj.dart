import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/duration_helper/duration_helper.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/core/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/core/utils/list_paginator/list_paginator.dart';
import 'package:youtube/core/utils/permissions/permissions.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/core/utils/reusable_global_widgets.dart';
import 'package:youtube/core/utils/share_helper/share_helper.dart';
import 'package:youtube/core/utils/shared_preferences_helper.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class UtilsInj {
  static Future<void> utilsInj() async {
    locator.registerLazySingleton<GlobalContextHelper>(
      () => GlobalContextHelper(),
    );

    locator.registerLazySingleton<ReusableGlobalFunctions>(
      () => ReusableGlobalFunctions(),
    );

    locator.registerLazySingleton<ReusableGlobalWidgets>(
      () => ReusableGlobalWidgets(),
    );

    locator.registerLazySingleton<SharedPreferencesHelper>(
      () => SharedPreferencesHelper(),
    );

    locator.registerLazySingleton<HiveDatabase>(
      () => HiveDatabase(),
    );

    locator.registerLazySingleton<HiveDatabaseHelper>(
      () => HiveDatabaseHelper(),
    );

    locator.registerLazySingleton<ListPaginator>(
      () => ListPaginator(),
    );

    locator.registerLazySingleton<ShareHelper>(
      () => ShareHelper(),
    );

    locator.registerLazySingleton<DurationHelper>(
      () => DurationHelper(),
    );

    locator.registerLazySingleton<YoutubeExplode>(
      () => YoutubeExplode(),
    );

    locator.registerLazySingleton<Permissions>(
      () => Permissions(),
    );
  }
}
