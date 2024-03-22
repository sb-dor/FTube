import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:path/path.dart' as p;
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class LibraryDownloadsStateModel {
  final _globalFunctions = locator<ReusableGlobalFunctions>();

  List<BaseDownloadedFileModel> files = [];

  String? fileExtensionName(BaseDownloadedFileModel? file) {
    final path = file?.downloadedPath;
    if (path == null) return '';
    final extension = p.extension(path);
    return _globalFunctions.removeSpaceFromStringForDownloadingVideo(extension);
  }
}
