import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/hive_database_helper/hive_database_helper.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;

class SearchScreenStateModel {
  final FocusNode focusNode = FocusNode();

  SpeechToText speechToText = SpeechToText();

  Timer? timerForAutoClosingSpeech, timerForMakingSuggestionRequest;

  final HiveDatabaseHelper hiveDatabaseHelper = HiveDatabaseHelper.instance;

  List<String> searchData = [], suggestData = [];

  List<ytv.Video> videos = [];

  TextEditingController searchController = TextEditingController(text: '');

  String? pageToken;

  bool hasMore = true, paginating = false;

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
}
