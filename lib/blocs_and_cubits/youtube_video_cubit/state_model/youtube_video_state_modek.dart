import 'dart:async';

import 'package:pod_player/pod_player.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class YoutubeVideoStateModel {
  var globalFunc = ReusableGlobalFunctions.instance;

  late VideoPlayerController playerController;

  bool loadingVideo = false;

  bool clickedUpOnVideo = false;

  Timer? timerForClickedUpOnVideo;

  String runningTime = '';

  bool stopVideo = false;

  void clearData() {
    loadingVideo = false;
    clickedUpOnVideo = false;
    runningTime = '';
  }
}
