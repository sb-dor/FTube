import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/youtube_video_player_screen/presentation/video_screen_player.dart';

final goRouter = GoRouter(routes: [
  GoRoute(
      // there always should be "/" route
      path: "/",
      builder: (context, state) {
        return const HomePage();
      },
      routes: [
        GoRoute(
            path: 'watch',
            name: '/watch',
            builder: (context, state) {
              debugPrint("other parameters: ${state.pathParameters}");
              debugPrint("fullPath ${state.fullPath}");
              debugPrint('extra: ${state.extra}');
              debugPrint("uri : ${state.uri}");
              debugPrint("uri query: ${state.uri.query}");
              debugPrint("uri query parameters: ${state.uri.queryParameters}");
              var param = state.uri.queryParameters;
              // reg ex -> .be\/(.{1,})\?
              // for finding id from url
              // get first group from regex there will be id inside of it
              return const VideoPlayerScreen(videoId: '1');
            })
      ]),
]);
