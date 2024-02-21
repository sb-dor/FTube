import 'package:youtube/core/db/db_floor.dart';
import 'package:floor/floor.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

abstract class DBInj {
  static Future<void> dbInj() async {
    final database = await $FloorDbFloor.databaseBuilder('ftube.db').build();

    locator.registerLazySingleton<DbFloor>(() => database);
  }
}
