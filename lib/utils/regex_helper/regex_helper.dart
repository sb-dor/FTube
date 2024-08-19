import 'package:flutter/cupertino.dart';

mixin class RegexHelper {
  String videoId(String text) {
    RegExp? regExp;
    // .be\/(.{1,})\?
    if (text.contains('shorts/')) {
      debugPrint("working 1");
      regExp = RegExp(r"shorts\/(\w{0,})");
    } else if (text.contains("youtu.be/")) {
      debugPrint("working 2");
      regExp = RegExp(r".be\/(.{1,})\?");
    } else {
      regExp = RegExp(r"v=([a-zA-Z0-9_-]+)");
    }

    final foundGroup = regExp.firstMatch(text);

    debugPrint("found group: ${foundGroup?.group(1)}");

    return foundGroup?.group(1) ?? '';
  }
}
