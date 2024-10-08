import 'package:flutter/cupertino.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/playlist_inner_screen_data_source.dart';
import 'package:youtube/utils/list_paginator/list_paginator.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class PlaylistInnerScreenDataSourceImpl implements PlaylistInnerScreenDataSource {
  @override
  Future<List<PlaylistModelDb>> getPlaylists({
    int page = 1,
    int currentListLength = 0,
  }) async {
    final dbOfPlaylists = locator<DbFloor>().playListDao;

    var playlists = await dbOfPlaylists.getAllPlaylists();

    for (int i = 0; i < playlists.length; i++) {
      playlists[i].videos = await dbOfPlaylists.getPlaylistAllVideos(playlists[i].id ?? 0);
      playlists[i].videos = playlists[i].videos?.reversed.toList();
    }

    playlists = playlists.reversed.toList();

    debugPrint("working here inner playlist screenj");

    final result = locator<ListPaginator>().paginateList<PlaylistModelDb>(
      wholeList: playlists,
      currentListLength: currentListLength,
    );

    return result;
  }

  @override
  Future<List<BaseVideoModelDb>> getAllLikes() async {
    return await locator<DbFloor>().likeDao.getAllLikes();
  }
}
