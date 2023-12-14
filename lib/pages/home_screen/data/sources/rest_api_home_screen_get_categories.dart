import 'package:flutter/material.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/pages/home_screen/data/repository/abs_home_screen_get_categories.dart';
import 'package:youtube/utils/constants.dart';

class RestApiHomeScreenGetCategories implements AbsHomeScreenGetCategories {
  @override
  Future<Map<String, dynamic>> getCategories() async {
    Map<String, dynamic> res = {};
    try {
      final response =
          await APISettings.dio.get(videoCategories + key + snippetPart + regionCode + language);

      if (response.statusCode != STATUS_SUCCESS) return {'server_error': true};

      Map<String, dynamic> json = response.data;

      List<dynamic> listCat = json['items'];

      List<VideoCategory> categories = listCat.map((e) => VideoCategory.fromJson(e)).toList();

      res['categories'] = categories;
      res['success'] = true;
    } catch (e) {
      debugPrint("getCategories error is $e");
      res['server_error'] = true;
    }
    return res;
  }
}
