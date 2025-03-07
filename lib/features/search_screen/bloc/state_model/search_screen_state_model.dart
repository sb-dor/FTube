import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_arrange.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_time.dart';
import 'package:youtube/core/youtube_data_api/models/order_by/order_by_details/order_by_type.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart' as ytv;

class SearchScreenStateModel {
  final GlobalContextHelper globalContext = GlobalContextHelper.instance;

  final FocusNode focusNode = FocusNode();

  SpeechToText speechToText = SpeechToText();

  Timer? timerForAutoClosingSpeech, timerForMakingSuggestionRequest, timerForCheckingPaginating;

  List<String> searchData = [], suggestData = [];

  List<ytv.Video> videos = [];

  TextEditingController searchController = TextEditingController(text: '');

  String? pageToken, lastSavedQuery;

  bool hasMore = true, paginating = false;

  OrderBy? orderBy = OrderBy.orderBy[4];

  void addAndPag({required List<ytv.Video> value, bool paginate = false}) {
    if (paginate) {
      videos.addAll(value);
    } else {
      videos = value;
    }
    // if (value.length < Constants.perPage) hasMore = false;
  }

  void clearData() {
    videos.clear();
    pageToken = '';
    hasMore = true;
  }

  void setOrderBy({OrderByType? type, OrderByTime? time, OrderByArrange? arrange}) =>
      orderBy = OrderBy.getOnCheck(
        type: type ?? orderBy?.orderByType,
        time: time ?? orderBy?.orderByTime,
        arrange: arrange ?? orderBy?.orderByArrange,
      );
}
