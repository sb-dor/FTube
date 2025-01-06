import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';
import 'package:collection/collection.dart';

 class GetVideoInformation {
  final YoutubeDataApi _youtubeDataApi;

  GetVideoInformation(this._youtubeDataApi);

  // Define a static method `getVideoInformation` to fetch video information based on a video ID
  Future<void> getVideoInformation({
    required String videoId, // The ID of the video to fetch information for
    required BuildContext
        context, // The BuildContext used for checking if the widget is still mounted
    required YoutubeVideoStateModel stateModel, // The state model that holds video data and state
    required Function(YoutubeVideoStates) emit, // A function to emit new states
  }) async {
    // Check if the context is still mounted; if not, exit the method
    if (!context.mounted) return;

    // Obtain the VideoInformationCubit from the context
    var videoInfoCubit = BlocProvider.of<VideoInformationCubit>(context);

    // Set the video information loading state in the cubit
    videoInfoCubit.loadingVideoInformationState();

    try {
      // Fetch video information using RestApiGetVideoData
      var data = await RestApiGetVideoData(youtubeDataApi: _youtubeDataApi).getVideoInfo(
        videoContent: TypeContent.snippet, // Specify the type of content to fetch
        videoId: videoId, // Provide the video ID
      );

      // Check if the data contains a server error
      if (data.containsKey('server_error') && data['server_error'] == true) {
        // Set the error state in the cubit if there is a server error
        videoInfoCubit.errorVideoInformationState();
      } else if (data.containsKey('success') && data['success'] == true) {
        // Update the state model with the fetched video data
        stateModel.videoData = data['item'];

        // Log the codec subtype of the first audio in the list for debugging
        // debugPrint"setting background audio type: ${stateModel.audios.first.codec.subtype}");

        // Create a MediaItem for background playback with the fetched video data
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

        // Emit the initial state with the updated state model
        emit(InitialYoutubeVideoState(stateModel));
        // Optionally, load additional snippet data if needed
        // await stateModel.video?.snippet?.loadSnippetData();

        // Set the loaded video information state in the cubit
        videoInfoCubit.loadedVideoInformationState();
        // Emit the initial state again with the updated state model
        emit(InitialYoutubeVideoState(stateModel));
      } else {
        // Set the error state in the cubit if the success key is not true
        videoInfoCubit.errorVideoInformationState();
      }
    } catch (e) {
      // Log any errors that occur during the process
      // debugPrint"getVideoInformation: $e");
      // Set the error state in the cubit if an exception is caught
      videoInfoCubit.errorVideoInformationState();
    }
  }
}
