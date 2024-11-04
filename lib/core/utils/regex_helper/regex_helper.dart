import 'package:flutter/cupertino.dart';

mixin class RegexHelper {
  String videoId(String text) {
    RegExp? regExp;
    // .be\/(.{1,})\?
    if (text.contains('shorts/')) {
      debugPrint("working 1");
      regExp = RegExp(r'shorts\/([^?]+)');
    } else if (text.contains("youtu.be/")) {
      debugPrint("working 2");
      regExp = RegExp(r"youtu\.be/([a-zA-Z0-9_-]+)");
    } else {
      regExp = RegExp(r"v=([a-zA-Z0-9_-]+)");
    }

    final foundGroup = regExp.firstMatch(text);

    debugPrint("found group: ${foundGroup?.group(1)}");

    return foundGroup?.group(1) ?? '';
  }

  String videoIdFromStorageSavedData(String text) {
    final regex = RegExp(r'_videoId_(.{1,}).mp4');
    final data = regex.firstMatch(text);
    return data?.group(1) ?? '';
  }
}
