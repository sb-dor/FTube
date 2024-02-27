import 'package:floor/floor.dart';
import 'package:youtube/core/db/db_floor.dart';

abstract class DbFloorMigrations {
  static List<Migration> migrations() {
    List<Migration> mig = [];

    if (Versions.currentVersion == Migration1to2.currentVersion) {
      mig.add(Migration1to2.migration1to2);
    }

    return mig;
  }
}

// all that stuff that you want to do, do in one migration and in one database version
abstract class Migration1to2 {
  static const lastVersion = 1;
  static const currentVersion = 2;

  ///                                   [versions]
  static final migration1to2 = Migration(lastVersion, currentVersion, (database) async {
    await database.execute('alter table video_history add column if not exists date_time TEXT');
  });
}
