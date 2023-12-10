import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/widgets/custom_clipper_helper/custom_clipper_helper.dart';
import 'widgets/video_informations_widgets/video_information_loaded_widget.dart';
import 'widgets/video_player_widgets/black_with_opacity_background.dart';
import 'widgets/video_player_widgets/last_next_stop_play_widget.dart';
import 'widgets/video_player_widgets/video_dutaion_information.dart';
import 'widgets/video_player_widgets/video_player_widget.dart';
import 'widgets/video_player_widgets/video_settings_button.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String videoId;

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => YoutubeVideoCubit()),
        BlocProvider(create: (_) => VideoInformationCubit()),
      ],
      child: _Player(videoId: videoId),
    );
  }
}

class _Player extends StatefulWidget {
  final String videoId;

  const _Player({Key? key, required this.videoId}) : super(key: key);

  @override
  State<_Player> createState() => _PlayerState();
}

class _PlayerState extends State<_Player> with SingleTickerProviderStateMixin {
  late final YoutubeVideoCubit _youtubeVideoCubit;
  late final DraggableScrollableController _scrollableController;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom
    ]);
    super.initState();
    _scrollableController = DraggableScrollableController();
    _youtubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context);
    _youtubeVideoCubit.init(url: widget.videoId, mixin: this, context: context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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
          initialChildSize: 1,
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
                        height: MediaQuery.of(context).size.height * 0.315,
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
                  Expanded(
                    child: ListView(
                      children: [
                        CustomerClipperWithShadow(
                          clipper: _Clipper(),
                          blurRadius: 1,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 100),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  VideoInformationLoadedWidget()
                                ],
                              ),
                            ),
                          ),
                        ),
                        // VideoInformationLoadedWidget(),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          });
    });
  }
}

class _Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 0);

    path.lineTo(0, size.height - 50);

    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
