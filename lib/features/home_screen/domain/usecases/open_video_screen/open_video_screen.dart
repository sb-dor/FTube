import 'package:flutter/material.dart';
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
      );
}
