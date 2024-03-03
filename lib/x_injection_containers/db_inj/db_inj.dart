import 'package:flutter/cupertino.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/db_floor_migrations.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

abstract class DBInj {
  static Future<void> dbInj() async {
    final migrations = DbFloorMigrations.migrations();

    debugPrint("migration length: ${migrations.length}");

    final db = $FloorDbFloor.databaseBuilder('ftube.db');

    if (migrations.isNotEmpty) db.addMigrations(migrations);

    final database = await db.build();

    locator.registerLazySingleton<DbFloor>(() => database);
  }
}
