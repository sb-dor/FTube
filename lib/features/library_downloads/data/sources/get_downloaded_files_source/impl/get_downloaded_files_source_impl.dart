import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/utils/mixins/storage_helper.dart';
import 'package:youtube/core/utils/regex_helper/regex_helper.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/get_downloaded_files_source.dart';
import 'package:collection/collection.dart';

class GetDownloadedFilesSourceImpl
    with StorageHelper, RegexHelper
    implements GetDownloadedFilesSource {
  GetDownloadedFilesSourceImpl({required DbFloor dbFloor}) : _dbFloor = dbFloor;

  final DbFloor _dbFloor;

  // Override the loadDownloadFiles method from the GetDownloadedFilesSource interface
  @override
  Future<List<BaseDownloadedFileModel>> loadDownloadFiles() async {
    // Get the directory for external storage (could be null if not available)
    final Directory? externalStorage = await getStorage();

    // List all files in the external storage directory and convert them to a list
    var dataFromStorage = await externalStorage?.list().toList();

    // Retrieve the list of downloaded files from the database using the locator pattern
    var dataFromDb = await _dbFloor.downloadedFiles.getDownloadedFiles();

    // Loop through each downloaded file in the database
    for (int i = 0; i < dataFromDb.length; i++) {
      // Check if the current platform is iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Find the corresponding file in external storage by matching the videoId in the path
        final findPath = (dataFromStorage ?? <FileSystemEntity>[]).firstWhereOrNull(
          (e) => e.path.contains(
              "videoId_${videoIdFromStorageSavedData(dataFromDb[i].downloadedPath ?? '')}"),
        );

        // If a matching file is found, update the path in the database model
        if (findPath != null) {
          dataFromDb[i].downloadedPath = findPath.path;
        }
      } else {
        // If not on iOS, check if the file exists in the external storage
        if (!(dataFromStorage ?? []).any((el) => el.path == dataFromDb[i].downloadedPath)) {
          // If the file doesn't exist, remove it from the database list
          dataFromDb.removeAt(i);

          // Decrement the index to adjust for the removed item
          i--;
        }
      }
    }

    // Reverse the order of the list (newest files first)
    dataFromDb = dataFromDb.reversed.toList();

    // Return the list of downloaded files
    return dataFromDb;
  }
}
