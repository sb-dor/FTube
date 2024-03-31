import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';

abstract class LibraryDownloadsEvent {}

class InitLibraryDownloadsEvent extends LibraryDownloadsEvent {}

class InitTypeOfPlayer extends InitLibraryDownloadsEvent {
  final BaseDownloadedFileModel? baseDownloadedFileModel;

  InitTypeOfPlayer({this.baseDownloadedFileModel});
}

class DisposeAudioPlayer extends InitLibraryDownloadsEvent {}
