import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract class GetVideo {
  // Define a static method `getVideo` to fetch video data based on a video ID
  static Future getVideo({
    required String videoId, // The ID of the video to fetch
    required BuildContext
    context, // The BuildContext used for checking if the widget is still mounted
    required YoutubeVideoStateModel stateModel, // The state model that holds video data and state
    required Function(YoutubeVideoStates) emit, // A function to emit new states
  }) async {
    // Check if the context is still mounted; if not, exit the method
    if (!context.mounted) return;

    // Set the temporary video ID in the state model
    stateModel.tempVideoId = videoId;

    // Fetch video manifest using the provided video ID
    final informationVideo = await stateModel.youtubeExplode?.videos.streamsClient.getManifest(
      videoId,
    );

    // Check if the context is still mounted after fetching the video manifest
    if (!context.mounted) return;

    // Filter video streams with sound, where size is at least 1 MB and is in MP4 format
    stateModel.videosWithSound =
        (informationVideo?.video ?? <VideoStreamInfo>[])
            .where(
              (e) =>
                  e.size.totalMegaBytes >= 1 &&
                  stateModel.globalFunc.checkMp4FromURI(value: e.url.toString()),
            )
            .toList();

    // Filter audio streams, where size is at least 1 MB and is in MP3 format
    stateModel.audios =
        (informationVideo?.audio ?? <AudioStreamInfo>[])
            .where(
              (el) =>
              // el.size.totalMegaBytes >= 1.5 &&
              stateModel.globalFunc.checkMp3FromURI(value: el.url.toString()),
            )
            .toList();

    // Sort audio streams by their size in ascending order
    stateModel.audios.sort((a, b) => a.size.totalMegaBytes.compareTo(b.size.totalMegaBytes));

    // for (var each in stateModel.audios) {
    //   // debugPrint"audio data media type: ${each.codec.subtype}");
    //   // debugPrint"audio data size: ${each.size.totalMegaBytes}");
    //   // debugPrint"audio data url: ${each.url}");
    // }

    // Filter out video streams with sound and without sound, keeping only those with size >= 1 MB
    stateModel.allVideos =
        (informationVideo?.video ?? <VideoStreamInfo>[])
            .where((el) => el.size.totalMegaBytes >= 1)
            .toList();

    // stateModel.allVideos.removeWhere((el) {
    //   int numb = el.size.totalMegaBytes.toInt();
    //   return el.size.totalMegaBytes >= numb &&
    //       el.size.totalMegaBytes < (numb + 0.7) &&
    //       !stateModel.globalFunc.checkMp4FromURI(value: el.url.toString());
    // });

    // Remove videos that are in MP4 format from the list of all videos
    stateModel.allVideos.removeWhere((el) {
      return stateModel.globalFunc.checkMp4FromURI(value: el.url.toString());
    });

    // Remove duplicate videos with lower quality from the state model
    await stateModel.removeSameVideosWithLowerQuality();

    // Sort all videos by size in ascending order
    stateModel.allVideos.sort((a, b) => a.size.totalMegaBytes.compareTo(b.size.totalMegaBytes));

    // Find the audio stream with the highest bitrate
    stateModel.tempMinAudioForVideo = informationVideo?.audioOnly.withHighestBitrate();

    // If a high-bitrate audio is found, update the list of audios
    if (stateModel.tempMinAudioForVideo != null) {
      stateModel.audios.removeWhere(
        (el) =>
            el.url.toString() == stateModel.tempMinAudioForVideo?.url.toString() ||
            el.size.totalMegaBytes == stateModel.tempMinAudioForVideo?.size.totalMegaBytes,
      );
      stateModel.audios.add(stateModel.tempMinAudioForVideo!);
    } else if (stateModel.audios.isNotEmpty) {
      // If no high-bitrate audio is found, set the tempMinAudioForVideo to the last audio in the list
      stateModel.tempMinAudioForVideo = stateModel.audios.last;
    }

    // If a high-bitrate audio is available, update the list of audios and filter videos
    if (stateModel.tempMinAudioForVideo != null) {
      stateModel.audios.removeWhere(
        (el) => el.url.toString().trim() == stateModel.tempMinAudioForVideo?.url.toString().trim(),
      );
      stateModel.audios.insert(0, stateModel.tempMinAudioForVideo!);
      stateModel.allVideos.removeWhere(
        (el) =>
            el.size.totalMegaBytes < (stateModel.tempMinAudioForVideo?.size.totalMegaBytes ?? 0.0),
      );
    }

    // Add videos with sound at the beginning of the allVideos list
    stateModel.allVideos.insertAll(0, stateModel.videosWithSound);

    // if (stateModel.videosWithSound.isNotEmpty) {
    //   stateModel.allVideos.removeWhere(
    //       (el) => el.size.totalMegaBytes < stateModel.videosWithSound.first.size.totalMegaBytes);
    // }
    //
    // stateModel.audios.sort((a, b) => a.size.totalMegaBytes.compareTo(b.size.totalMegaBytes));
    //
    // if (stateModel.audios.isNotEmpty) {
    //   stateModel.tempMinAudioForVideo = stateModel.audios.last;
    // } else {}

    // Check if the context is still mounted before proceeding
    if (!context.mounted) return;

    // Remove duplicated videos from the state model
    await stateModel.deleteDuplicatedVideos();

    // Check if the context is still mounted after deleting duplicated videos
    if (!context.mounted) return;

    // Get the minimum stream video from the list
    final minStreamVideo = await stateModel.minStreamFromArray();

    // Check if the context is still mounted before proceeding
    if (!context.mounted) return;

    // Set up the video player controller with the minimum stream video URL
    stateModel.playerController = VideoPlayerController.networkUrl(
      Uri.parse(minStreamVideo.url.toString()),
    );

    // debugPrint"video url: ${ minStreamVideo.url}");

    // Set the URL for overlay run in the state model
    stateModel.videoUrlForOverlayRun = minStreamVideo.url.toString();

    // Check if the context is still mounted before proceeding
    if (!context.mounted) return;

    // Initialize and play the video
    await stateModel.playerController?.initialize();
    await stateModel.playerController?.play();

    // Set loading state to false
    stateModel.loadingVideo = false;

    // Emit the initial state with the updated state model
    emit(InitialYoutubeVideoState(stateModel));
  }
}
