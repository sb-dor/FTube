import 'package:go_router/go_router.dart';
import 'package:youtube/features/home_page.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/video_screen_player.dart';

final goRouter = GoRouter(routes: [
  GoRoute(
      // there always should be "/" route
      path: "/",
      builder: (context, state) {
        return const HomePage();
      },
      routes: [
        // example for:
        /// [https://www.youtube.com/watch?v=NQDinnsjabs]
        GoRoute(
            path: 'watch',
            name: '/watch',
            builder: (context, state) {
              return VideoPlayerScreen(
                videoId: state.uri.queryParameters['v'] ?? 'NQDinnsjabs',
                showOverlay: () {},
                parentContext: context,
              );
            }),

        // example for:
        /// [https://www.youtube.com/shorts/CMUtk1pG46M]
        /// [https://youtube.com/shorts/CMUtk1pG46M?si=ifR0sxH97_PvcPMB]
        GoRoute(
            path: 'shorts/:id',
            builder: (context, state) {
              return VideoPlayerScreen(
                videoId: state.pathParameters['id'] ?? "NQDinnsjabs",
                showOverlay: () {},
                parentContext: context,
              );
            }),
        // example for:
        /// [https://youtu.be/NQDinnsjabs?si=VtdU7uiZoWY2qsdb]
        GoRoute(
            path: ':id',
            builder: (context, state) {
              return VideoPlayerScreen(
                videoId: state.pathParameters['id'] ?? "NQDinnsjabs",
                showOverlay: () {},
                parentContext: context,
              );
            })
      ]),
]);
