import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_states.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/widgets/video_info_subs_buttons/video_info_subs_buttons_loaded_widget.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/widgets/video_info_subs_buttons/video_info_subs_buttons_loading_widget.dart';
import 'package:youtube/pages/youtube_video_player_screen/presentation/widgets/video_informations_widgets/video_information_loading_widget.dart';
import 'package:youtube/widgets/custom_clipper_helper/custom_clipper_helper.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'widgets/video_info_like_buttons_widgets/video_info_like_button_loaded_widgets.dart';
import 'widgets/video_info_like_buttons_widgets/video_info_like_button_loading_widgets.dart';
import 'widgets/video_informations_widgets/video_information_loaded_widget.dart';
import 'widgets/video_player_widgets/black_with_opacity_background.dart';
import 'widgets/video_player_widgets/last_next_stop_play_widget.dart';
import 'widgets/video_player_widgets/video_dutaion_information.dart';
import 'widgets/video_player_widgets/video_player_widget.dart';
import 'widgets/video_player_widgets/video_settings_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({
    Key? key,
    required this.videoId,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late final YoutubeVideoCubit _youtubeVideoCubit;
  late final VideoInformationCubit _videoInformationCubit;
  late final DraggableScrollableController _scrollableController;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    super.initState();
    _scrollableController = DraggableScrollableController();
    _youtubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context);
    _videoInformationCubit = BlocProvider.of<VideoInformationCubit>(context);
    _youtubeVideoCubit.init(url: widget.videoId, mixin: this, context: context);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _youtubeVideoCubit.dispose();
    _videoInformationCubit.loadingVideoInformationState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final youtubeStates = context.watch<YoutubeVideoCubit>().state;
      final videoInformationStates = context.watch<VideoInformationCubit>().state;

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
                        height: MediaQuery.of(context).size.height * 0.315,
                        child: Stack(children: [
                          if (youtubeStateModel.video?.snippet != null)
                            Positioned.fill(
                                child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ImageLoaderWidget(
                                url: youtubeStateModel.video?.snippet?.thumbnailHigh?.url ?? '',
                                errorImageUrl: "assets/custom_images/error_image.png",
                                boxFit: BoxFit.fill,
                              ),
                            )),
                          const Positioned.fill(
                              child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.red,
                            ),
                          )),
                        ]))
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
                        Stack(
                          children: [
                            CustomerClipperWithShadow(
                              clipper: _Clipper(),
                              blurRadius: 1,
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 80),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      //
                                      if (videoInformationStates is LoadingVideoInformationState)
                                        const VideoInformationLoadingWidget()
                                      else if (videoInformationStates is ErrorVideoInformationState)
                                        const SizedBox()
                                      else
                                        const VideoInformationLoadedWidget(),

                                      //
                                      const SizedBox(height: 10),
                                      if (videoInformationStates is LoadingVideoInformationState)
                                        const VideoInfoLikeButtonLoadingWidgets()
                                      else if (videoInformationStates is ErrorVideoInformationState)
                                        const SizedBox()
                                      else
                                        const VideoInfoLikeButtonLoadedWidget()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (videoInformationStates is LoadingVideoInformationState)
                              const VideoInfoSubsButtonsLoadingWidget()
                            else if (videoInformationStates is ErrorVideoInformationState)
                              const SizedBox()
                            else
                              const VideoInfoSubsButtonsLoadedWidget(),
                          ],
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
