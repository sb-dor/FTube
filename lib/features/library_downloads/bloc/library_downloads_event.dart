import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';

abstract class LibraryDownloadsEvent {}

class InitLibraryDownloadsEvent extends LibraryDownloadsEvent {}

class SaveAppStorageFileInGalleryEvent extends LibraryDownloadsEvent {
  final BaseDownloadedFileModel? baseDownloadedFileModel;

  SaveAppStorageFileInGalleryEvent({required this.baseDownloadedFileModel});
}
