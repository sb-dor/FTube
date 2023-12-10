import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube/models/video_modes/video.dart' as v;

class YoutubeVideoStateModel {
  var globalFunc = ReusableGlobalFunctions.instance;

  YoutubeExplode? youtubeExplode;

  late AnimationController playPauseController;

  late Animation<double> playPauseAnimation;

  VideoPlayerController? playerController;

  bool loadingVideo = false;

  bool clickedUpOnVideo = false;

  Timer? timerForClickedUpOnVideo;

  String runningTime = '';

  bool stopVideo = false;

  List<VideoStreamInfo> videosWithSound = [];

  List<VideoStreamInfo> allVideos = [];

  v.Video? video;

  Future<void> deleteDuplicatedVideos() async {
    for (int i = 0; i < videosWithSound.length; i++) {
      for (int j = i; j < videosWithSound.length; j++) {
        if (j == i) continue;
        if (videosWithSound[i].videoQuality.name != videosWithSound[j].videoQuality.name) continue;
        videosWithSound.removeAt(j);
        j--;
      }
    }
  }

  Future<VideoStreamInfo> minStreamFromArray() async {
    VideoStreamInfo streamInfo = videosWithSound.first;
    for (var each in videosWithSound) {
      if (each.size.totalMegaBytes < streamInfo.size.totalMegaBytes) {
        streamInfo = each;
      }
    }
    return streamInfo;
  }

  void clearData() {
    playerController = null;
    loadingVideo = false;
    clickedUpOnVideo = false;
    runningTime = '';
  }
}

//'https://packaged-media.redd.it/5cm4p6o15b4c1/pb/m2-res_640p.'
//             'mp4?m=DASHPlaylist.mpd&v=1&e=1701795600&s=75de0a1556c6f64c2a4a574716722a4c7829d9d1#t=0'
