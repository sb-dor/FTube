import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/global_context_helper.dart';
import 'package:youtube/features/top_overlay_feature/view/overlay_opener/top_overlay_logic.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/video_screen_player.dart';

abstract class OpenVideoScreen {
  static Future<void> openVideoScreen({
    required BuildContext context,
    required String videoId,
    String? videoThumb,
  }) async =>
      await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => VideoPlayerScreen(
          videoId: videoId,
          videoThumb: videoThumb,
        ),
      ).then((v) {
        if (context.mounted) {
          final model = context.read<YoutubeVideoCubit>().state.youtubeVideoStateModel;
          TopOverlayLogic.instance.showOverlay(
            context,
            model.videoUrlForOverlayRun ?? '',
            model.lastVideoDurationForMediaBackground,
          );
        }
      });
}
