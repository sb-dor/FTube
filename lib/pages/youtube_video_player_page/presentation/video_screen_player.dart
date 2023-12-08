import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import '../cubit/youtube_video_cubit.dart';
import 'widgets/black_with_opacity_background.dart';
import 'widgets/last_next_stop_play_widget.dart';
import 'widgets/video_dutaion_information.dart';
import 'widgets/video_player_widget.dart';
import 'widgets/video_settings_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late final YoutubeVideoCubit _youtubeVideoCubit;
  late final DraggableScrollableController _scrollableController;

  @override
  void initState() {
    super.initState();
    _scrollableController = DraggableScrollableController();
    _youtubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context);
    _youtubeVideoCubit.init(url: widget.videoId, mixin: this);
  }

  @override
  void dispose() {
    _youtubeVideoCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final youtubeStates = context.watch<YoutubeVideoCubit>().state;

      var youtubeStateModel = youtubeStates.youtubeVideoStateModel;

      return DraggableScrollableSheet(
          controller: _scrollableController,
          initialChildSize: 0.9650,
          expand: false,
          snap: true,
          builder: (context, controller) {
            return SafeArea(
              child: Scaffold(
                body: Column(children: [
                  if (youtubeStateModel.loadingVideo || youtubeStateModel.playerController == null)
                    Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: 210,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ))
                  else
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 210,
                        child: Stack(
                          children: [
                            const VideoPlayerWidget(),
                            const BlackWithOpacityBackground(),
                            if (youtubeStateModel.clickedUpOnVideo)
                              const VideoDurationInformation(),
                            if (youtubeStateModel.clickedUpOnVideo) const LastNextStopPlayWidget(),
                            if (youtubeStateModel.clickedUpOnVideo) const VideoSettingsButton(),
                          ],
                        )),
                  Expanded(child: ListView(children: []))
                ]),
              ),
            );
          });
    });
  }
}
