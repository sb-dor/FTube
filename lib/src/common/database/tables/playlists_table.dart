import 'package:drift/drift.dart';

/// User playlists.
@DataClassName('PlaylistRow')
class Playlists extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().nullable()();

  @override
  String get tableName => 'playlists';
}
