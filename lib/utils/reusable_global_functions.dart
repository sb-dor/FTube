import 'package:youtube/utils/constants.dart';

class ReusableGlobalFunctions {
  static ReusableGlobalFunctions? _instance;

  static ReusableGlobalFunctions get instance => _instance ??= ReusableGlobalFunctions._();

  ReusableGlobalFunctions._();

  int checkIsListHasMorePageInt(
      {required List<dynamic> list, required int page, int limitInPage = perPage}) {
    if (list.length < limitInPage) {
      page = 1;
    } else {
      page++;
    }
    return page;
  }

//this fun will check is there more list in pag (returns boolean)
  bool checkIsListHasMorePageBool({required List<dynamic> list, int limitInPage = perPage}) {
    if (list.length < limitInPage) {
      return false;
    } else {
      return true;
    }
  }

  String getFromDuration(Duration? duration) {
    String res = '';
    int days = duration?.inDays ?? 0;
    if (days != 0) {
      res += '$days';
    }
    int hours = duration?.inHours ?? 0;
    if (hours != 0) {
      res += '$hours:';
    }
    int minutes = duration?.inMinutes ?? 0;
    if (minutes >= 0 && minutes <= 9) {
      res += "0$minutes:";
    } else {
      res += '$minutes:';
    }
    int seconds = duration?.inSeconds ?? 0;
    if (seconds >= 0 && seconds <= 9) {
      res += "0$seconds";
    } else {
      res += '$seconds';
    }

    return res;
  }
}
