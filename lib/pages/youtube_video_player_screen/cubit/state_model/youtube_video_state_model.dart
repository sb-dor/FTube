import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/downloading_video_info.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube/models/video_modes/video.dart' as v;
import 'package:youtube/youtube_data_api/models/video_data.dart' as ytv;

class YoutubeVideoStateModel {
  var globalFunc = ReusableGlobalFunctions.instance;

  YoutubeExplode? youtubeExplode;

  late AnimationController playPauseController;

  late Animation<double> playPauseAnimation;

  VideoPlayerController? playerController;

  bool loadingVideo = false, clickedUpOnVideo = false, stopVideo = false;

  Timer? timerForClickedUpOnVideo;

  String runningTime = '';

  List<VideoStreamInfo> videosWithSound = [], allVideos = [];

  List<AudioStreamInfo> audios = [];

  AudioStreamInfo? tempMinAudioForVideo;

  ytv.VideoData? videoData;

  DownloadingType? downloadingType;

  CancelToken cancelVideoToken = CancelToken(), cancelAudioToken = CancelToken();

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

  Future<void> removeSameVideosWithLowerQuality() async {
    debugPrint("before deleting: ${allVideos.length}");
    for (int i = 0; i < allVideos.length; i++) {
      var tempVideo = allVideos[i];
      for (int j = 0; j < allVideos.length; j++) {
        if (allVideos[j].qualityLabel.trim() == tempVideo.qualityLabel.trim() &&
            allVideos[j].size.totalMegaBytes < tempVideo.size.totalMegaBytes) {
          allVideos.removeAt(j);
          j--;
        }
      }
    }
    debugPrint("after deleting: ${allVideos.length}");
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

  void cancelTime() {
    if ((timerForClickedUpOnVideo?.isActive ?? false)) {
      timerForClickedUpOnVideo?.cancel();
    }
  }

  void clearData() {
    playerController = null;
    loadingVideo = false;
    clickedUpOnVideo = false;
    runningTime = '';
    youtubeExplode = null;
    videoData = null;
    tempMinAudioForVideo = null;
  }
}

//'https://packaged-media.redd.it/5cm4p6o15b4c1/pb/m2-res_640p.'
//             'mp4?m=DASHPlaylist.mpd&v=1&e=1701795600&s=75de0a1556c6f64c2a4a574716722a4c7829d9d1#t=0'
