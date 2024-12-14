import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/db_floor_migrations.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';

final class DbFloorFactory implements AsyncFactory<DbFloor> {
  @override
  Future<DbFloor> create() async {
    final migrations = DbFloorMigrations.migrations();

    // debugPrint("migration length: ${migrations.length}");

    final db = $FloorDbFloor.databaseBuilder('ftube.db');

    if (migrations.isNotEmpty) db.addMigrations(migrations);

    final database = await db.build();

    return database;
  }
}
