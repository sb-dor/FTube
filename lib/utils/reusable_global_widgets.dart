import 'package:flutter/material.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/video_screen_player.dart';

class ReusableGlobalWidgets {
  static ReusableGlobalWidgets? _instance;

  static ReusableGlobalWidgets get instance => _instance ??= ReusableGlobalWidgets._();

  ReusableGlobalWidgets._();
}
