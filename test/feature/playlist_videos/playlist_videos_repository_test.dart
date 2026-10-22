import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlist_videos/data/playlist_videos_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

VideoItem _video(String id) => VideoItem(id: id, title: id);

void main() {
  late AppDatabase db;
  late PlaylistVideosRepositoryImpl repository;
  late int music;
  late int news;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = PlaylistVideosRepositoryImpl(database: db);
    music = await db.into(db.playlists).insert(PlaylistsCompanion.insert(name: const Value('M')));
    news = await db.into(db.playlists).insert(PlaylistsCompanion.insert(name: const Value('N')));
    for (final id in ['a', 'b', 'c']) {
      await db.into(db.playlistVideos).insert(_video(id).toPlaylistVideoCompanion(music));
    }
    await db.into(db.playlistVideos).insert(_video('z').toPlaylistVideoCompanion(news));
    for (final id in ['x', 'y']) {
      await db.into(db.likes).insert(_video(id).toLikeCompanion());
    }
  });
  tearDown(() => db.close());

  test('returns the videos of one playlist, newest first, page by page', () async {
    final playlist = UserPlaylistSummary(id: music, name: 'M', videoCount: 3);

    final page = await repository.watchVideos(playlist: playlist, limit: 2).first;
    expect(page.videos.map((v) => v.id), ['c', 'b']);
    expect(page.hasMore, isTrue);

    final all = await repository.watchVideos(playlist: playlist, limit: 15).first;
    expect(all.videos.map((v) => v.id), ['c', 'b', 'a']);
    expect(all.hasMore, isFalse);
  });

  test('reads liked videos for the virtual playlist', () async {
    final page = await repository
        .watchVideos(playlist: const LikedPlaylistSummary(videoCount: 2), limit: 15)
        .first;
    expect(page.videos.map((v) => v.id), ['y', 'x']);
  });

  test('emits again when a video is removed', () async {
    final updates = StreamIterator(
      repository.watchVideos(
        playlist: UserPlaylistSummary(id: music, name: 'M', videoCount: 3),
        limit: 15,
      ),
    );
    expect(await updates.moveNext(), isTrue);
    await (db.delete(db.playlistVideos)..where((row) => row.videoId.equals('b'))).go();
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.videos.map((v) => v.id), ['c', 'a']);
    await updates.cancel();
  });
}
