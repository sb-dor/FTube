import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube/core/animations/fade_animation.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/core/utils/reusable_global_widgets.dart';
import 'package:youtube/core/utils/share_helper/share_helper.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class VideoInfoLikeButtonLoadedWidget extends StatelessWidget {
  const VideoInfoLikeButtonLoadedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(
      builder: (context, state) {
        final currentState = state.youtubeVideoStateModel;
        return FadeAnimation(
          beginInterval: 0.7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap:
                          () => context.read<YoutubeVideoCubit>().likeVideo(),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Icon(
                            currentState.isVideoAddedToFavorites
                                ? FontAwesomeIcons.solidThumbsUp
                                : FontAwesomeIcons.thumbsUp,
                            weight: 0.5,
                            color:
                                currentState.isVideoAddedToFavorites
                                    ? Colors.red
                                    : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextWidget(
                    text: currentState.videoData?.video?.likeCount ?? '-',
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    size: 12,
                    letterSpacing: 0.9,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: () => [],
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.all(10),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.thumbsDown,
                            weight: 0.5,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap:
                          () async => await ShareHelper().shareVideoPath(
                            currentState.tempVideoId,
                          ),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.all(10),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.share,
                            weight: 0.5,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const TextWidget(
                    text: "Share",
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    size: 12,
                    letterSpacing: 0.9,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: () async {
                        final VideoModelDb? model = VideoModelDb.fromVideoData(
                          currentState.videoData,
                        );
                        model?.videoThumbnailUrl = currentState.videoPicture;
                        await ReusableGlobalWidgets.instance
                            .showPlaylistAddingPopup(
                              context: context,
                              videoModelDb: model,
                              onFunc: () async {
                                await Future.delayed(
                                  const Duration(milliseconds: 500),
                                );
                                if (context.mounted) {
                                  context
                                      .read<YoutubeVideoCubit>()
                                      .checkVideoInBookmarks(
                                        videoId:
                                            currentState.tempVideoId ?? '0',
                                      );
                                }
                              },
                            );
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.all(10),
                        child: Center(
                          child: Icon(
                            currentState.isVideoAddedToBookMarks
                                ? FontAwesomeIcons.solidBookmark
                                : FontAwesomeIcons.bookmark,
                            weight: 0.5,
                            color:
                                currentState.isVideoAddedToBookMarks
                                    ? Colors.red
                                    : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const TextWidget(
                    text: "To bookmarks",
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    size: 12,
                    letterSpacing: 0.9,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
