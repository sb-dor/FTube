import 'package:flutter/material.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/video_screen_player.dart';

abstract class OpenVideoScreen {
  static Future<void> openVideoScreen({
    required BuildContext context,
    required BuildContext parentContext,
    required String videoId,
    required void Function() showOverlay,
    String? videoThumb,
  }) async => await showModalBottomSheet(
    isScrollControlled: true,
    useRootNavigator: true,
    context: context,
    builder:
        (context) => VideoPlayerScreen(
          videoId: videoId,
          videoThumb: videoThumb,
          showOverlay: showOverlay,
          parentContext: parentContext,
        ),
  );
}
