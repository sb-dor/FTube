import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';

class LibraryDownloadsStateModel {
  final globalFunctions = ReusableGlobalFunctions.instance;

  List<BaseDownloadedFileModel> files = [];

  String toolTipMessage(BaseDownloadedFileModel? baseDownloadedFileModel) {
    if (baseDownloadedFileModel == null) return '';
    final result = globalFunctions.fileExtensionName(baseDownloadedFileModel);
    if (result == 'mp4') {
      return "Save in Gallery";
    } else {
      return "Save in Downloads";
    }
  }
}
