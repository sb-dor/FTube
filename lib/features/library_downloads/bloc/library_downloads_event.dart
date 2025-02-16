import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';

sealed class LibraryDownloadsEvent {}

final class InitLibraryDownloadsEvent extends LibraryDownloadsEvent {}

final class SaveAppStorageFileInGalleryEvent extends LibraryDownloadsEvent {
  final BaseDownloadedFileModel? baseDownloadedFileModel;

  SaveAppStorageFileInGalleryEvent({required this.baseDownloadedFileModel});
}
