import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/usecases/open_popups/open_downloading_video_popup.dart';

abstract class OpenDownloadingErrorPopup {
  static void downloadingErrorPopup(BuildContext context) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Something went wrong while video was downloading"),
            content: const Text(
                'Please, try to download the "Recommended" video from video downloading section'),
            actions: _buttons(context),
          );
        });
  }

  static List<Widget> _buttons(BuildContext context) {
    return [
      TextButton(onPressed: () => _popUpFunc(context), child: const Text("OK")),
    ];
  }

  static void _popUpFunc(BuildContext context) {
    context.read<YoutubeVideoCubit>().onDownloadingError(context);
    Navigator.pop(context);
    OpenDownloadingVideoPopup.openDownloadingVideoPopup(context: context);
  }
}
