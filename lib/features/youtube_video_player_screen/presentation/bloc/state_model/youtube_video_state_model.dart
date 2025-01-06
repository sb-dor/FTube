import 'dart:async';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube/core/youtube_data_api/models/video_data.dart' as ytvdata;

class YoutubeVideoStateModel {
  var globalFunc = ReusableGlobalFunctions.instance;

  YoutubeExplode? youtubeExplode;

  VideoPlayerController? playerController;

  bool loadingVideo = false,
      clickedUpOnVideo = false,
      stopVideo = false,
      isVideoAddedToBookMarks = false,
      isVideoAddedToFavorites = false,
      loadedMusicForBackground = false;

  Timer? timerForClickedUpOnVideo;

  String runningTime = '';

  List<VideoStreamInfo> videosWithSound = [], allVideos = [];

  List<AudioStreamInfo> audios = [];

  AudioStreamInfo? tempMinAudioForVideo;

  ytvdata.VideoData? videoData;

  MediaItem? mediaItemForRunningInBackground;

  Duration? lastVideoDurationForMediaBackground;

  DownloadingType? downloadingType;

  CancelToken? cancelVideoToken = CancelToken(), cancelAudioToken = CancelToken();

  Future<Isolate>? isolateForDownloadingAudio;

  String? tempVideoId, videoPicture, videoUrlForOverlayRun;

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
    Map<String, VideoStreamInfo> getUnique = {};

    for (var each in allVideos) {
      // debugPrint"all videos: ${each.qualityLabel} | ${each.size.totalMegaBytes}");
      if (getUnique.containsKey(each.qualityLabel.trim())) {
        var value = getUnique[each.qualityLabel.trim()] as VideoStreamInfo;
        if (each.size.totalMegaBytes > value.size.totalMegaBytes) {
          getUnique[each.qualityLabel.trim()] = each;
        }
      } else {
        getUnique[each.qualityLabel.trim()] = each;
      }
    }
    allVideos = getUnique.entries.map((e) => e.value).toList();

    for (var each in allVideos) {
      // debugPrint"all after videos: ${each.qualityLabel} | ${each.size.totalMegaBytes}");
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

  void cancelTime() {
    if ((timerForClickedUpOnVideo?.isActive ?? false)) {
      timerForClickedUpOnVideo?.cancel();
    }
  }

  void clearData() {
    playerController?.dispose();
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
