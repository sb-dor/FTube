import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/utils/constants.dart';
import 'package:path/path.dart' as p;

class ReusableGlobalFunctions {
  // static ReusableGlobalFunctions? _instance;

  // static ReusableGlobalFunctions get instance => _instance ??= ReusableGlobalFunctions._();

  // ReusableGlobalFunctions._();

  int checkIsListHasMorePageInt(
      {required List<dynamic> list, required int page, int limitInPage = Constants.perPage}) {
    if (list.length < limitInPage) {
      page = 1;
    } else {
      page++;
    }
    return page;
  }

//this fun will check is there more list in pag (returns boolean)
  bool checkIsListHasMorePageBool(
      {required List<dynamic> list, int limitInPage = Constants.perPage}) {
    if (list.length < limitInPage) {
      return false;
    } else {
      return true;
    }
  }

  bool checkMp4FromURI({required String value}) {
    var reg = RegExp('mime=video%2Fmp4');
    var reg2 = RegExp('ratebypass=yes');
    return reg.hasMatch(value) && reg2.hasMatch(value);
  }

  bool checkMp3FromURI({required String value}) {
    var reg = RegExp("mime=audio%2Fmp4");
    var reg2 = RegExp("mime=audio%2F3gpp");
    var reg3 = RegExp("mime=audio%2Fwebm");
    var reg4 = RegExp('gir=yes');
    return ((reg.hasMatch(value) || reg2.hasMatch(value) || reg3.hasMatch(value)) &&
        reg4.hasMatch(value));
  }

  String generateRandomString({int length = 10}) {
    final random = Random();
    const characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    return String.fromCharCodes(
      List.generate(
        length,
        (index) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  void showToast({
    required String msg,
    bool typeError = false,
    double fontSize = 14,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Toast toastLength = Toast.LENGTH_SHORT,
    Color textColor = Colors.white,
  }) async {
    await Fluttertoast.cancel();
    await Fluttertoast.showToast(
      msg: msg,
      backgroundColor: typeError ? Colors.red : null,
      fontSize: fontSize,
      gravity: gravity,
      textColor: textColor,
      toastLength: toastLength,
    );
  }

  String removeSpaceFromStringForDownloadingVideo(String value) {
    String res = '';
    for (int i = 0; i < value.length; i++) {
      if (value[i] == ' ' || value[i] == '.') continue;
      if (value[i] == '-' ||
          value[i] == ":" ||
          value[i] == "\"" ||
          value[i] == "'" ||
          value[i] == ',' ||
          value[i] == '/' ||
          value[i] == "\\" ||
          value[i] == '@' ||
          value[i] == '!' ||
          value[i] == '\$' ||
          value[i] == '%' ||
          value[i] == '^' ||
          value[i] == '&' ||
          value[i] == '*' ||
          value[i] == '(' ||
          value[i] == ')' ||
          value[i] == '|' ||
          value[i] == '?') {
        res += '_';
        continue;
      }
      res += value[i];
    }
    return res;
  }

  Map<String, dynamic> convertMap(Map<dynamic, dynamic> originalMap) {
    Map<String, dynamic> newMap = {};

    originalMap.forEach((key, value) {
      if (key is String) {
        newMap[key] = value;
      } else {
        newMap[key.toString()] = value;
      }
      if (value is Map<dynamic, dynamic>) {
        newMap[key.toString()] = convertMap(value);
      }
    });

    return newMap;
  }

  String? fileExtensionName(BaseDownloadedFileModel? file) {
    final path = file?.downloadedPath;
    if (path == null) return '';
    final extension = p.extension(path);
    return removeSpaceFromStringForDownloadingVideo(extension);
  }
}
