import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/models/video_modes/video.dart' as v;

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
          videoContent: TypeContent.snippet, videoId: videoId);

      if (data.containsKey('server_error') && data['server_error'] == true) {
        videoInfoCubit.errorVideoInformationState();
      } else if (data.containsKey('success') && data['success'] == true) {
        stateModel.video = v.Video.fromJson(data['item']);
        emit(InitialYoutubeVideoState(stateModel));
        await stateModel.video?.snippet?.loadSnippetData();
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
