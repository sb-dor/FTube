import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/utils/hive_database_helper/hive_database.dart';
import 'package:youtube/utils/hive_database_helper/hive_database_helper.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/utils/reusable_global_widgets.dart';
import 'package:youtube/utils/shared_preferences_helper.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

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
  }
}
