import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';

abstract class OpenDisableDownloadingPopup {
  static void openDisableDownloadingPopup(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Cancel download"),
            content: const Text("Do you want to continue?"),
            actions: _buttons(context),
          );
        });
  }

  static List<Widget> _buttons(BuildContext context) {
    return [
      TextButton(
          onPressed: () async => await context.read<YoutubeVideoCubit>().cancelTheVideo(),
          child: const Text("Continue")),
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
    ];
  }
}
