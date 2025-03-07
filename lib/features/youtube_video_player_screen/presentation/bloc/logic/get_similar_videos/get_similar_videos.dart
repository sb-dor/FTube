import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/core/youtube_data_api/models/video_data.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/state_model/youtube_video_state_model.dart';

class GetSimilarVideos {
  final YoutubeDataApi _youtubeDataApi;

  GetSimilarVideos(this._youtubeDataApi);

  // Define a static method `getSimilarVideos` to fetch similar videos based on a video title
  Future<void> getSimilarVideos({
    required String
    videoTitle, // The title of the video to find similar videos for
    required YoutubeVideoStateModel
    stateModel, // The state model that holds video data and state
    required BuildContext context, // The BuildContext used for accessing cubits
    required bool paginating, // A flag to indicate if paginating results
  }) async {
    // Obtain the SimilarVideosCubit from the context
    final similarVideosCubit = BlocProvider.of<SimilarVideosCubit>(context);

    // Check if there are more similar videos to load; if not, exit the method
    if (!similarVideosCubit.state.similarVideoStateModel.hasMore) return;

    // If not paginating, clear existing state and set the loading state
    if (!paginating) similarVideosCubit.clearAndSetLoadingState();

    // Fetch similar videos using the RestApiGetVideoData
    final data = await RestApiGetVideoData(
      youtubeDataApi: _youtubeDataApi,
    ).getSearchVideo(q: videoTitle.trim());

    // Check if the data contains a server error
    if (data.containsKey("server_error")) {
      // Set the error state in the cubit if there is a server error
      similarVideosCubit.errorSimilarVideosState();
    } else if (data.containsKey('success')) {
      // If the success key is present, process the list of videos
      final List<Video> videos = data['videos'];
      similarVideosCubit.addVideosAndSetLoadedState(videos);
      // Optionally, perform additional processing with an isolate
      // _isolate(similarVideosCubit, videos);
    } else {
      // Set the error state in the cubit if the success key is not present
      similarVideosCubit.clearAndSerErrorState();
    }
  }

  // Define a static method `_isolate` to handle video data processing in an isolate
  static Future<void> _isolate(
    SimilarVideosCubit similarVideosCubit,
    List<Video> videos,
  ) async {
    // Prepare a map of videos to send to the isolate
    final Map<String, dynamic> sendingList = {
      "list": videos.map((e) => e.toJson()).toList(),
    };

    // Convert the map to a JSON string
    final toStringing = jsonEncode(sendingList);

    // Create a receive port for communication with the isolate
    final rp = ReceivePort();
    // Spawn a new isolate and pass the receive port's send port
    Isolate.spawn(_isolateFunc, rp.sendPort);

    // Convert the receive port to a broadcast stream
    final broadCast = rp.asBroadcastStream();

    // Retrieve the send port from the isolate
    final SendPort communicatorSendPort = await broadCast.first;

    // Send the JSON string to the isolate
    communicatorSendPort.send(toStringing);

    // Listen for messages from the isolate
    broadCast.listen((message) {
      VideoData? videoData;
      if (message != null) videoData = VideoData.fromJson(message);
      // Update the cubit with the processed video data
      similarVideosCubit.changeVideoData(videoData);
    });
  }

  // Define a static method `_isolateFunc` to be executed in an isolate
  static void _isolateFunc(SendPort sp) async {
    // Create a receive port for communication with the main isolate
    final isoLateRP = ReceivePort();
    sp.send(isoLateRP.sendPort);

    // Take messages from the receive port that are of type String
    final message =
        isoLateRP.takeWhile((element) => element is String).cast<String>();

    // Initialize the YouTube Data API
    // Injections.initYoutubeDataApi();

    // Process each message received from the main isolate
    await for (final eachM in message) {
      // Decode the JSON string to a map
      final Map<String, dynamic> gettingData = jsonDecode(eachM);

      // Extract the list of videos from the map
      List<dynamic> list = [];
      if (gettingData.containsKey('list')) {
        list = gettingData['list'];
      }
      // Convert the list of dynamic objects to a list of Video objects
      final List<Video> videos = list.map((e) => Video.fromIsolate(e)).toList();

      // Fetch video data for each video and send it back to the main isolate
      await Future.wait(
        videos.map(
          (e) => e.getVideoData(YoutubeDataApi()).then((value) {
            sp.send(e.videoData?.toJson());
          }),
        ),
      );
    }
  }
}
