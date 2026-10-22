import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlist_selection/data/playlist_selection_repository.dart';
import 'package:youtube/src/feature/playlist_selection/models/playlist_option.dart';

const _video = VideoItem(id: 'v', title: 'Video', channelName: 'Channel');

void main() {
  late AppDatabase db;
  late PlaylistSelectionRepositoryImpl repository;
  late int music;
  late int news;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = PlaylistSelectionRepositoryImpl(database: db);
    music = await db.into(db.playlists).insert(PlaylistsCompanion.insert(name: const Value('M')));
    news = await db.into(db.playlists).insert(PlaylistsCompanion.insert(name: const Value('N')));
  });
  tearDown(() => db.close());

  Future<List<(int?, String?)>> rows() async => [
    for (final row in await db.select(db.playlistVideos).get()) (row.playlistId, row.videoId),
  ];

  test('lists user playlists newest first and never the liked videos', () async {
    await db.into(db.likes).insert(_video.toLikeCompanion());

    final playlists = await repository.watchPlaylists().first;

    expect(playlists, [PlaylistOption(id: news, name: 'N'), PlaylistOption(id: music, name: 'M')]);
  });

  test('watchPlaylists emits a newly created playlist', () async {
    final updates = StreamIterator(repository.watchPlaylists());
    expect(await updates.moveNext(), isTrue);

    final created = await db
        .into(db.playlists)
        .insert(PlaylistsCompanion.insert(name: const Value('New')));
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.first, PlaylistOption(id: created, name: 'New'));
    await updates.cancel();
  });

  test('assign moves the video into the chosen playlist', () async {
    expect(await repository.playlistOf('v'), isNull);

    await repository.assign(_video, playlistId: music);
    expect(await repository.playlistOf('v'), music);

    await repository.assign(_video, playlistId: news);
    expect(await repository.playlistOf('v'), news);
    expect(await rows(), [(news, 'v')]);

    final saved = await db.select(db.playlistVideos).getSingle();
    expect(saved.toVideoItem().channelName, 'Channel');
  });

  test('assign with no playlist removes the video from all playlists', () async {
    await db.into(db.playlistVideos).insert(_video.toPlaylistVideoCompanion(music));
    await db.into(db.playlistVideos).insert(_video.toPlaylistVideoCompanion(news));
    await db
        .into(db.playlistVideos)
        .insert(const VideoItem(id: 'other', title: 'o').toPlaylistVideoCompanion(music));

    await repository.assign(_video, playlistId: null);

    expect(await rows(), [(music, 'other')]);
    expect(await repository.playlistOf('v'), isNull);
  });
}
