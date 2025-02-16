import 'package:floor/floor.dart';
import 'package:youtube/core/db/db_floor.dart';

abstract class DbFloorMigrations {
  static List<Migration> migrations() {
    final List<Migration> mig = [];

    if (Versions.currentVersion == Migration1to2.updatingVersion) {
      mig.add(Migration1to2.migration1to2);
    }

    if (Versions.currentVersion == Migration3to4.updatingVersion) {
      mig.add(Migration3to4.migration3to4);
    }

    if (Versions.currentVersion == Migration4to5.updatingVersion) {
      mig.add(Migration4to5.migration4to5);
    }

    return mig;
  }
}

// all that stuff that you want to do, do in one migration and in one database version
abstract class Migration1to2 {
  static const lastVersion = 1;
  static const updatingVersion = 2;

  ///                                   [versions]
  static final migration1to2 = Migration(lastVersion, updatingVersion, (database) async {
    await database.execute('alter table video_history add column if not exists date_time TEXT');
  });
}

abstract class Migration3to4 {
  static const lastVersion = 3;
  static const updatingVersion = 4;

  static final migration3to4 = Migration(lastVersion, updatingVersion, (database) async {
    await database
        .execute('CREATE TABLE IF NOT EXISTS `likes_table` (`id` INTEGER PRIMARY KEY AUTOINCREMENT,'
            ' `videoId` TEXT, `videoThumbnailUrl` TEXT,'
            ' `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT,'
            ' `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT)');
  });
}

abstract class Migration4to5 {
  static const lastVersion = 4;
  static const updatingVersion = 5;
  static final migration4to5 = Migration(lastVersion, updatingVersion, (database) async {
    await database.execute(
        'CREATE TABLE IF NOT EXISTS `file_downloads` (`id` INTEGER PRIMARY KEY AUTOINCREMENT,'
        ' `name` TEXT, `downloaded_path` TEXT, `image_path` TEXT, `views` TEXT,'
        ' `created_at` TEXT, `channel_name` TEXT)');
  });
}
