import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlists/data/playlist_summary_queries.dart';
import 'package:youtube/src/feature/playlists/data/playlists_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

VideoItem _video(String id, {String? thumbnail}) =>
    VideoItem(id: id, title: 'Video $id', thumbnailUrl: thumbnail);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> playlist(String name) =>
      db.into(db.playlists).insert(PlaylistsCompanion.insert(name: Value(name)));

  Future<void> addVideo(int playlistId, VideoItem video) =>
      db.into(db.playlistVideos).insert(video.toPlaylistVideoCompanion(playlistId));

  group('PlaylistSummaryQueries', () {
    test('lists user playlists newest first with count and newest thumbnail', () async {
      final music = await playlist('Music');
      final empty = await playlist('Empty');
      final news = await playlist('News');
      await addVideo(music, _video('a', thumbnail: 'https://img/a.jpg'));
      await addVideo(music, _video('b', thumbnail: 'https://img/b.jpg'));
      await addVideo(news, _video('c'));

      final summaries = await db.userPlaylistSummaries();

      expect(summaries, [
        UserPlaylistSummary(
          id: news,
          name: 'News',
          videoCount: 1,
          thumbnailUrl: 'https://i.ytimg.com/vi/c/hqdefault.jpg',
        ),
        UserPlaylistSummary(id: empty, name: 'Empty', videoCount: 0),
        UserPlaylistSummary(
          id: music,
          name: 'Music',
          videoCount: 2,
          thumbnailUrl: 'https://img/b.jpg',
        ),
      ]);
    });

    test('limits user playlists to the newest ones', () async {
      for (var i = 0; i < 5; i++) {
        await playlist('P$i');
      }

      final summaries = await db.userPlaylistSummaries(limit: 2);

      expect(summaries.map((p) => p.name), ['P4', 'P3']);
    });

    test('has no liked playlist until something is liked', () async {
      expect(await db.likedPlaylistSummary(), isNull);

      await db.into(db.likes).insert(_video('x', thumbnail: 'https://img/x.jpg').toLikeCompanion());
      await db.into(db.likes).insert(_video('y', thumbnail: 'https://img/y.jpg').toLikeCompanion());

      expect(
        await db.likedPlaylistSummary(),
        const LikedPlaylistSummary(videoCount: 2, thumbnailUrl: 'https://img/y.jpg'),
      );
    });
  });

  group('PlaylistsRepositoryImpl', () {
    test('puts liked videos first and updates on writes', () async {
      final repository = PlaylistsRepositoryImpl(database: db);
      await playlist('Music');
      final updates = StreamIterator(repository.watchPlaylists());

      expect(await updates.moveNext(), isTrue);
      expect(updates.current.map((p) => p.runtimeType), [UserPlaylistSummary]);

      await db.into(db.likes).insert(_video('x').toLikeCompanion());
      expect(await updates.moveNext(), isTrue);
      expect(updates.current.first, isA<LikedPlaylistSummary>());
      expect(updates.current.length, 2);

      await updates.cancel();
    });
  });
}
