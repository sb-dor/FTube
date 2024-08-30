import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/utils/enums.dart';
import 'package:collection/collection.dart';

abstract class GetVideoInformation {
  static Future<void> getVideoInformation({
    required String videoId,
    required BuildContext context,
    required YoutubeVideoStateModel stateModel,
    required Function(YoutubeVideoStates) emit,
  }) async {
    if (!context.mounted) return;

    var videoInfoCubit = BlocProvider.of<VideoInformationCubit>(context);

    videoInfoCubit.loadingVideoInformationState();

    try {
      var data = await RestApiGetVideoData.getVideoInfo(
        videoContent: TypeContent.snippet,
        videoId: videoId,
      );

      if (data.containsKey('server_error') && data['server_error'] == true) {
        videoInfoCubit.errorVideoInformationState();
      } else if (data.containsKey('success') && data['success'] == true) {
        stateModel.videoData = data['item'];

        debugPrint("setting background audio type: ${stateModel.audios.first.codec.subtype}");

        stateModel.mediaItemForRunningInBackground = MediaItem(
          id: (stateModel.audios.firstWhereOrNull((audio) => audio.codec.subtype == 'mp4') ??
                  stateModel.audios.first)
              .url
              .toString(),
          title: stateModel.videoData?.video?.title ?? '',
          artist: stateModel.videoData?.video?.channelName ?? '',
          album: stateModel.videoData?.video?.description ?? '',
          artUri: Uri.parse(
            stateModel.videoPicture ?? "assets/custom_images/error_image.png",
          ),
          duration: stateModel.playerController!.value.duration,
        );

        emit(InitialYoutubeVideoState(stateModel));
        // await stateModel.video?.snippet?.loadSnippetData();

        videoInfoCubit.loadedVideoInformationState();
        emit(InitialYoutubeVideoState(stateModel));
      } else {
        videoInfoCubit.errorVideoInformationState();
      }
    } catch (e) {
      debugPrint("getVideoInformation: $e");
      videoInfoCubit.errorVideoInformationState();
    }
  }
}
