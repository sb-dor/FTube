import 'package:flutter/cupertino.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/api/api_urls.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/utils/enums.dart';

abstract class RestApiGetChannelData {
  static Future<Map<String, dynamic>> channel({
    required TypeContent typeContent,
    required String? channelId,
  }) async {
    Map<String, dynamic> res = {};
    try {
      String part = _partBuilder(typeContent);

      var response = await APISettings.dio.get(
        channels + key + part,
        queryParameters: {'id': channelId},
      );

      if (response.statusCode != Constants.STATUS_SUCCESS) return {"server_error": true};

      Map<String, dynamic> json = response.data;

      if (json.containsKey('items')) {
        List<dynamic> items = json['items'];

        if (items.isNotEmpty) {
          res['item'] = items.first;
          res['success'] = true;
        }
      }
    } catch (e) {
      // debugPrint"channel error is: $e");
      res['server_error'] = true;
    }
    return res;
  }

  static String _partBuilder(TypeContent videoContent) {
    switch (videoContent) {
      case TypeContent.snippet:
        return snippetPart;
      case TypeContent.contentDetails:
        return contentDetailsPart;
      case TypeContent.statistics:
        return statisticsPart;
      default:
        return contentDetailsPart;
    }
  }
}
