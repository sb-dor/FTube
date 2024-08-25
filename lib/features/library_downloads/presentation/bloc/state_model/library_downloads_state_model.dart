import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class LibraryDownloadsStateModel {
  final globalFunctions = locator<ReusableGlobalFunctions>();

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
