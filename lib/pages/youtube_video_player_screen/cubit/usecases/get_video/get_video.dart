import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class GetVideo {
  static Future getVideo({
    required String videoId,
    required BuildContext context,
    required YoutubeVideoStateModel stateModel,
    required Function(YoutubeVideoStates) emit,
  }) async {
    if (!context.mounted) return;

    var informationVideo =
        await stateModel.youtubeExplode?.videos.streamsClient.getManifest(videoId);

    if (!context.mounted) return;

    stateModel.videosWithSound = (informationVideo?.video ?? <VideoStreamInfo>[])
        .where((e) =>
            e.size.totalMegaBytes >= 1 &&
            stateModel.globalFunc.checkMp4FromURI(
              value: e.url.toString(),
            ))
        .toList();

    if (!context.mounted) return;

    await stateModel.deleteDuplicatedVideos();

    if (!context.mounted) return;

    var minStreamVideo = await stateModel.minStreamFromArray();

    if (!context.mounted) return;
    //
    for (var element in stateModel.videosWithSound) {
      debugPrint("______");
      log(element.url.toString());
      log(element.videoQuality.name);
      debugPrint("______");
    }

    if (!context.mounted) return;

    stateModel.playerController =
        VideoPlayerController.networkUrl(Uri.parse(minStreamVideo.url.toString()));

    if (!context.mounted) return;

    await stateModel.playerController?.initialize();

    await stateModel.playerController?.play();

    stateModel.loadingVideo = false;

    emit(InitialYoutubeVideoState(stateModel));
  }
}
