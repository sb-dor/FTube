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
}
