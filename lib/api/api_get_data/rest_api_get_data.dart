import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/channel_model/channel.dart';
import 'package:youtube/utils/constants.dart';

abstract class RestApiGetData {
  static Future<Map<String, dynamic>> channel({required String channelId}) async {
    Map<String, dynamic> res = {};
    try {
      var response = await APISettings.dio.get(
        channels + key + snippetPart,
        queryParameters: {'id': channelId},
      );

      if (response.statusCode != STATUS_SUCCESS) return {"server_error": true};

      Map<String, dynamic> json = response.data;

      if (json.containsKey('items')) {
        List<dynamic> items = json['items'];

        if (items.isNotEmpty) {
          res['channel'] = Channel.fromJson(items[0]);
          res['success'] = true;
        }
      }
    } catch (e) {
      res['server_error'] = true;
    }
    return res;
  }
}
