import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/hive_database_helper/hive_database_helper.dart';

class SearchScreenStateModel {

  final HiveDatabaseHelper hiveDatabaseHelper = HiveDatabaseHelper.instance;

  List<String> searchData = [];

  List<Video> videos = [];

  TextEditingController searchController = TextEditingController(text: '');

  Future<void> initLastSearchData() async {}
}
