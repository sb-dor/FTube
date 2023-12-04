import 'package:flutter/material.dart';
import 'package:youtube/pages/global_screen/video_player_screen/video_sceen_player.dart';

class ReusableGlobalWidgets {
  static ReusableGlobalWidgets? _instance;

  static ReusableGlobalWidgets get instance => _instance ??= ReusableGlobalWidgets._();

  ReusableGlobalWidgets._();

  void showVideoScreen({required BuildContext context, required String videoId}) =>
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => VideoPlayerScreen(videoId: videoId),
      );
}
