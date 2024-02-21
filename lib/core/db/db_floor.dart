import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'video_db/data_access_object/video_model_db_dao.dart';
import 'video_db/video_model_db/video_model_db.dart';

part 'db_floor.g.dart';

// last version 1
@Database(version: 1, entities: [
  VideoModelDb,
])
abstract class DbFloor extends FloorDatabase {
  VideoModelDbDao get videoDbDao;
}
