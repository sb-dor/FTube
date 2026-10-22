import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';

abstract interface class IPlaylistCreationRepository {
  /// Creates a playlist named [name] and returns its id.
  Future<int> create(String name);
}

final class PlaylistCreationRepositoryImpl implements IPlaylistCreationRepository {
  PlaylistCreationRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<int> create(String name) =>
      _database.into(_database.playlists).insert(PlaylistsCompanion.insert(name: Value(name)));
}
