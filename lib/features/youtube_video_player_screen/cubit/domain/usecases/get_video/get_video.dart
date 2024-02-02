import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';
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

    // all videos with sound
    stateModel.videosWithSound = (informationVideo?.video ?? <VideoStreamInfo>[])
        .where((e) =>
            e.size.totalMegaBytes >= 1 &&
            stateModel.globalFunc.checkMp4FromURI(
              value: e.url.toString(),
            ))
        .toList();

    // array of sounds only
    stateModel.audios = (informationVideo?.audio ?? <AudioStreamInfo>[])
        .where((el) =>
            // el.size.totalMegaBytes >= 1.5 &&
            stateModel.globalFunc.checkMp3FromURI(
              value: el.url.toString(),
            ))
        .toList();

    stateModel.audios.sort((a, b) => a.size.totalMegaBytes.compareTo(b.size.totalMegaBytes));

    for (var each in stateModel.audios) {
      debugPrint("media type: ${each.codec.subtype}");
      debugPrint("media size: ${each.size.totalMegaBytes}");
      debugPrint("media url: ${each.url}");
    }

    // all videos both with and without sound
    stateModel.allVideos = (informationVideo?.video ?? <VideoStreamInfo>[])
        .where((el) => el.size.totalMegaBytes >= 1)
        .toList();

    // sort all videos both with and without sound with their size (MB)

    // stateModel.allVideos.removeWhere((el) {
    //   int numb = el.size.totalMegaBytes.toInt();
    //   return el.size.totalMegaBytes >= numb &&
    //       el.size.totalMegaBytes < (numb + 0.7) &&
    //       !stateModel.globalFunc.checkMp4FromURI(value: el.url.toString());
    // });

    stateModel.allVideos.removeWhere((el) {
      return stateModel.globalFunc.checkMp4FromURI(value: el.url.toString());
    });

    debugPrint("before deleting: ${stateModel.allVideos.length}");

    await stateModel.removeSameVideosWithLowerQuality();

    debugPrint("after deleting: ${stateModel.allVideos.length}");

    stateModel.allVideos.sort((a, b) => a.size.totalMegaBytes.compareTo(b.size.totalMegaBytes));

    stateModel.allVideos.insertAll(0, stateModel.videosWithSound);

    // if (stateModel.videosWithSound.isNotEmpty) {
    //   stateModel.allVideos.removeWhere(
    //       (el) => el.size.totalMegaBytes < stateModel.videosWithSound.first.size.totalMegaBytes);
    // }

    // stateModel.audios.sort((a, b) => a.size.totalMegaBytes.compareTo(b.size.totalMegaBytes));

    // if (stateModel.audios.isNotEmpty) {
    //   stateModel.tempMinAudioForVideo = stateModel.audios.last;
    // } else {
    stateModel.tempMinAudioForVideo = informationVideo?.audioOnly.withHighestBitrate();

    if (stateModel.tempMinAudioForVideo != null) {
      stateModel.audios.removeWhere(
        (el) =>
            el.url.toString() == stateModel.tempMinAudioForVideo?.url.toString() ||
            el.size.totalMegaBytes == stateModel.tempMinAudioForVideo?.size.totalMegaBytes,
      );
      stateModel.audios.add(stateModel.tempMinAudioForVideo!);
    }
    // }

    debugPrint("temp min audio for video : ${stateModel.tempMinAudioForVideo?.codec.subtype}"
        " | size: ${stateModel.tempMinAudioForVideo?.size.totalMegaBytes}");

    if (!context.mounted) return;

    await stateModel.deleteDuplicatedVideos();

    if (!context.mounted) return;

    var minStreamVideo = await stateModel.minStreamFromArray();

    if (!context.mounted) return;
    //
    // for (var element in stateModel.videosWithSound) {
    //   debugPrint("______");
    //   log(element.url.toString());
    //   log(element.videoQuality.name);
    // }

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
