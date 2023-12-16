import 'package:flutter/cupertino.dart';
import 'package:jiffy/jiffy.dart';
import 'package:youtube/utils/constants.dart';

abstract class JiffyHelper {
  static String timePassed(String? data) {
    Jiffy.setLocale('ru');
    data = data ?? tempDateTime;
    return Jiffy.parse(data).fromNow();
  }

  static String _removeLettersFromDateTime(String data) {
    String res = '';
    for (int i = 0; i < data.length; i++) {
      if (data[i] != '-' || int.tryParse(data[i]) == null || data[i] == ' ') continue;
      res += data[i];
    }
    debugPrint("result of string is : $res");
    return res;
  }
}
