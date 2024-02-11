import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart';
import 'package:youtube/youtube_data_api/models/video_data.dart';

abstract class GetSimilarVideos {
  static Future<void> getSimilarVideos({
    required String videoTitle,
    required YoutubeVideoStateModel stateModel,
    required BuildContext context,
    required bool paginating,
  }) async {
    var similarVideosCubit = BlocProvider.of<SimilarVideosCubit>(context);

    if (!similarVideosCubit.state.similarVideoStateModel.hasMore) return;

    if (!paginating) similarVideosCubit.loadingSimilarVideosState();

    var data = await RestApiGetVideoData.getSearchVideo(q: videoTitle.trim());

    debugPrint("coming data: $data");

    if (data.containsKey("server_error")) {
      similarVideosCubit.errorSimilarVideosState();
    } else if (data.containsKey('success')) {
      List<Video> videos = data['videos'];
      similarVideosCubit.addVideosAndSetLoadedState(videos);
      _isolate(similarVideosCubit, videos);
    } else {
      similarVideosCubit.clearAndSerErrorState();
    }
  }

  static Future<void> _isolate(SimilarVideosCubit similarVideosCubit, List<Video> videos) async {
    Map<String, dynamic> sendingList = {
      "list": videos.map((e) => e.toJson()).toList(),
    };

    var toStringing = jsonEncode(sendingList);

    final rp = ReceivePort();
    Isolate.spawn(_isolateFunc, rp.sendPort);

    final broadCast = rp.asBroadcastStream();

    final SendPort communicatorSendPort = await broadCast.first;

    communicatorSendPort.send(toStringing);

    broadCast.listen((message) {
      VideoData? videoData;
      if (message != null) videoData = VideoData.fromJson(message);
      similarVideosCubit.changeVideoData(videoData);
    });
  }

  static void _isolateFunc(SendPort sp) async {
    final isoLateRP = ReceivePort();
    sp.send(isoLateRP.sendPort);

    final message = isoLateRP.takeWhile((element) => element is String).cast<String>();

    initYoutubeDataApi();

    await for (final eachM in message) {
      Map<String, dynamic> gettingData = jsonDecode(eachM);

      List<dynamic> list = [];

      if (gettingData.containsKey('list')) {
        list = gettingData['list'];
      }
      List<Video> videos = list.map((e) => Video.fromIsolate(e)).toList();

      await Future.wait(videos.map((e) => e.getVideoData().then((value) {
            sp.send(e.videoData?.toJson());
          })));
    }
  }
}
