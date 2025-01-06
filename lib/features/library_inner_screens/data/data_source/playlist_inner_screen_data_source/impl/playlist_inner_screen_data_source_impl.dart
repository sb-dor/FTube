import 'package:flutter/cupertino.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/utils/list_paginator/list_paginator.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/playlist_inner_screen_data_source.dart';

class PlaylistInnerScreenDataSourceImpl implements PlaylistInnerScreenDataSource {
  final DbFloor _dbFloor;

  PlaylistInnerScreenDataSourceImpl(this._dbFloor);

  @override
  Future<List<PlaylistModelDb>> getPlaylists({
    int page = 1,
    int currentListLength = 0,
  }) async {
    final dbOfPlaylists = _dbFloor.playListDao;

    var playlists = await dbOfPlaylists.getAllPlaylists();

    for (int i = 0; i < playlists.length; i++) {
      playlists[i].videos = await dbOfPlaylists.getPlaylistAllVideos(playlists[i].id ?? 0);
      playlists[i].videos = playlists[i].videos?.reversed.toList();
    }

    playlists = playlists.reversed.toList();

    // debugPrint"working here inner playlist screenj");

    final result = ListPaginator().paginateList<PlaylistModelDb>(
      wholeList: playlists,
      currentListLength: currentListLength,
    );

    return result;
  }

  @override
  Future<List<BaseVideoModelDb>> getAllLikes() async {
    return await _dbFloor.likeDao.getAllLikes();
  }
}
