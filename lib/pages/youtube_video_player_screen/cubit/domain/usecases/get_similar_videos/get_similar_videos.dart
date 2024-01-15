import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/state_model/youtube_video_state_model.dart';
import 'package:youtube/youtube_data_api/models/video.dart';
import 'package:youtube/youtube_data_api/models/video_data.dart';

abstract class GetSimilarVideos {
  static Future<void> getSimilarVideos({
    required String videoTitle,
    required YoutubeVideoStateModel stateModel,
    required BuildContext context,
  }) async {
    var similarVideosCubit = BlocProvider.of<SimilarVideosCubit>(context);

    similarVideosCubit.state.similarVideos.clear();

    similarVideosCubit.loadingSimilarVideosState();

    var data = await RestApiGetVideoData.getSearchVideo(q: videoTitle.trim());

    debugPrint("coming data: $data");

    if (data.containsKey("server_error")) {
      similarVideosCubit.errorSimilarVideosState();
    } else if (data.containsKey('success')) {
      List<Video> videos = data['videos'];
      similarVideosCubit.state.similarVideos.addAll(videos);
      similarVideosCubit.loadedSimilarVideosState();
      _isolate(similarVideosCubit);
    } else {
      similarVideosCubit.state.similarVideos.clear();
      similarVideosCubit.errorSimilarVideosState();
    }
  }

  static Future<void> _isolate(SimilarVideosCubit similarVideosCubit) async {
    Map<String, dynamic> sendingList = {
      "list": similarVideosCubit.state.similarVideos.map((e) => e.toJson()).toList(),
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
      for (var each in similarVideosCubit.state.similarVideos) {
        if (each.videoId == videoData?.video?.videoId) {
          each.loadingVideoData = false;
          each.videoData = videoData?.clone();
        }
      }
      similarVideosCubit.loadedSimilarVideosState();
    });
  }

  static void _isolateFunc(SendPort sp) async {
    final isoLateRP = ReceivePort();
    sp.send(isoLateRP.sendPort);

    final message = isoLateRP.takeWhile((element) => element is String).cast<String>();

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
