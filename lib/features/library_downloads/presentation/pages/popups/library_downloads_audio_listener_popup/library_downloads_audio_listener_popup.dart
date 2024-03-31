import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_event.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:youtube/utils/global_context_helper.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class LibraryDownloadsAudioListenerPopup extends StatefulWidget {
  final BaseDownloadedFileModel? baseDownloadedFileModel;

  const LibraryDownloadsAudioListenerPopup({
    super.key,
    required this.baseDownloadedFileModel,
  });

  @override
  State<LibraryDownloadsAudioListenerPopup> createState() =>
      _LibraryDownloadsAudioListenerPopupState();
}

class _LibraryDownloadsAudioListenerPopupState extends State<LibraryDownloadsAudioListenerPopup> {
  final GlobalContextHelper _globalContextHelper = locator<GlobalContextHelper>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<LibraryDownloadsBloc>().add(
          InitTypeOfPlayer(
            baseDownloadedFileModel: widget.baseDownloadedFileModel,
          ),
        );
  }

  @override
  void dispose() {
    _globalContextHelper.globalNavigatorContext.currentContext!
        .read<LibraryDownloadsBloc>()
        .add(DisposeAudioPlayer());
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final libraryDownloadsBloc = context.watch<LibraryDownloadsBloc>();

      // data
      final libraryDownloadsStateModel = libraryDownloadsBloc.state.libraryDownloadsStateModel;
      return Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // audio_video_progress_bar  -> package
              ProgressBar(
                progress:
                    libraryDownloadsStateModel.audioPlayer?.position ?? const Duration(seconds: 0),
                total:
                    libraryDownloadsStateModel.audioPlayer?.duration ?? const Duration(seconds: 0),
                buffered: libraryDownloadsStateModel.audioPlayer?.bufferedPosition ??
                    const Duration(seconds: 0),
                onSeek: (duration) {},
              ),
            ],
          ),
        ),
      );
    });
  }
}
