import 'package:flutter/cupertino.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/list_paginator/list_paginator.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/history_inner_screen_data_source.dart';

class HistoryInnerScreenDataSourceLocally implements HistoryInnerScreenDataSource {
  @override
  Future<List<BaseVideoModelDb>> getHistory({int page = 1, int currentListLength = 0}) async {
    final data = await locator<DbFloor>().videoDbDao.getAllVideos().then(
          (value) => value.reversed.toList(),
        );

    debugPrint("whole list :${data.length} | $currentListLength");

    List<BaseVideoModelDb> currentData = locator<ListPaginator>().paginateList<BaseVideoModelDb>(
      wholeList: data,
      currentListLength: currentListLength,
    );

    return currentData;
  }
}
