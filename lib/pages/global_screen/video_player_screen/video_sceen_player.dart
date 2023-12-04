import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/blocs_and_cubits/youtube_video_cubit/youtube_video_cubit.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubeVideoCubit _youtubeVideoCubit;
  late final DraggableScrollableController _scrollableController;

  @override
  void initState() {
    super.initState();
    _scrollableController = DraggableScrollableController();
    _youtubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context);
    _youtubeVideoCubit.init(url: widget.videoId);
  }

  @override
  void dispose() {
    _youtubeVideoCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final youtubeStates = context.watch<YoutubeVideoCubit>();

      return DraggableScrollableSheet(
          controller: _scrollableController,
          initialChildSize: 0.96,
          expand: false,
          snap: true,
          builder: (context, controller) {
            return SafeArea(
              child: Scaffold(
                body: Column(children: [
                  PodVideoPlayer(
                    matchVideoAspectRatioToFrame: true,
                    controller: youtubeStates.playerController,
                    alwaysShowProgressBar: false,
                  ),
                  Expanded(child: ListView(children: []))
                ]),
              ),
            );
          });
    });
  }
}
