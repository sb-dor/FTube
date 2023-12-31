import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/hive_database_helper/hive_database_helper.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchScreenStateModel {
  final FocusNode focusNode = FocusNode();

  SpeechToText speechToText = SpeechToText();

  Timer? timerForAutoClosingSpeech;

  final HiveDatabaseHelper hiveDatabaseHelper = HiveDatabaseHelper.instance;

  List<String> searchData = [];

  List<Video> videos = [];

  TextEditingController searchController = TextEditingController(text: '');

  String? pageToken;

  bool hasMore = true;

  void addAndPag({required List<Video> value, bool paginate = false}) {
    if (paginate) {
      videos.addAll(value);
    } else {
      videos = value;
    }
    if (value.length < Constants.perPage) hasMore = false;
  }

  void clearData() {
    videos.clear();
    pageToken = '';
    hasMore = true;
  }
}
