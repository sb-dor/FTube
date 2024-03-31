import 'package:flutter/material.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/features/library_downloads/presentation/pages/popups/library_downloads_audio_listener_popup/library_downloads_audio_listener_popup.dart';

abstract class OpenLibraryDownloadsAudioListenerPopup {
  static void openLibraryDownloadsAudioListenerPopup(
    BuildContext context,
    BaseDownloadedFileModel? downloadedFileModel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return LibraryDownloadsAudioListenerPopup(
          baseDownloadedFileModel: downloadedFileModel,
        );
      },
    );
  }
}
