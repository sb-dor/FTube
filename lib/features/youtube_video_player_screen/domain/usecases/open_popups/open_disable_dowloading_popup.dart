import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';

import 'open_downloading_video_popup.dart';

abstract class OpenDisableDownloadingPopup {
  static void openDisableDownloadingPopup(
    BuildContext context, {
    bool showOpenDownloadsPopup = false,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel download"),
          content: const Text("Do you want to continue?"),
          actions: _buttons(context, showOpenDownloadsPopup: showOpenDownloadsPopup),
        );
      },
    );
  }

  static List<Widget> _buttons(BuildContext context, {bool showOpenDownloadsPopup = false}) {
    return [
      if (showOpenDownloadsPopup)
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            OpenDownloadingVideoPopup.openDownloadingVideoPopup(context: context);
          },
          child: const Text("Open Downloads"),
        ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          await context.read<YoutubeVideoCubit>().cancelTheVideo();
        },
        child: const Text("Continue"),
      ),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
    ];
  }
}
