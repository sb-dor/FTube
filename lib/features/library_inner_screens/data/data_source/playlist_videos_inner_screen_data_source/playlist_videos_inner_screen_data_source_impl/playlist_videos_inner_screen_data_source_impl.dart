import 'package:flutter/cupertino.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source.dart';
import 'package:youtube/utils/list_paginator/list_paginator.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class PlaylistVideosInnerScreenDataSourceImpl implements PlaylistVideosInnerScreenDataSource {
  @override
  Future<List<BaseVideoModelDb>> getPlaylistsVideos({
    int page = 1,
    int currentListLength = 0,
    PlaylistModelDb? playlistModelDb,
  }) async {
    var playlistVideos = await locator<DbFloor>().playListDao.getPlaylistAllVideos(
          playlistModelDb?.id ?? 0,
        );

    debugPrint("coming here getplaylistvideos");

    playlistVideos = playlistVideos.reversed.toList();

    final result = locator<ListPaginator>().paginateList(
      wholeList: playlistVideos,
      currentListLength: currentListLength,
    );

    return result;
  }

  @override
  Future<List<BaseVideoModelDb>> getLikedVideos({int page = 1, int currentListLength = 0}) async {
    final data = await locator<DbFloor>().likeDao.getAllLikes();
    final result = locator<ListPaginator>().paginateList(
      wholeList: data,
      currentListLength: currentListLength,
    );
    return result;
  }
}
