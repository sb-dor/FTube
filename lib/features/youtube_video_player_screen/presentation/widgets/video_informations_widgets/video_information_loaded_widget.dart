import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/animations/fade_animation.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_states.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_disable_dowloading_popup.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_downloading_error_popup_info.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_downloading_video_popup.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoInformationLoadedWidget extends StatelessWidget {
  const VideoInformationLoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var youtubeCubit = context.watch<YoutubeVideoCubit>().state;
      var downloadingVideoCubit = context.watch<VideoDownloadingCubit>().state;

      var currentState = youtubeCubit.youtubeVideoStateModel;
      // var channel = currentState.video?.snippet?.channel;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeAnimation(
            beginInterval: 0.1,
            child: TextWidget(
              text: currentState.videoData?.video?.title ?? '-',
              size: 18,
              maxLines: 2,
              overFlow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          FadeAnimation(
            beginInterval: 0.1,
            child: RichText(
                text: TextSpan(children: [
              WidgetSpan(
                  child: TextWidget(
                text: "${currentState.videoData?.video?.viewCount ?? ''}",
                color: Colors.grey,
                size: 12,
                fontWeight: FontWeight.w500,
              )),
              const WidgetSpan(
                  child: TextWidget(
                text: " • ",
                size: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              )),
              WidgetSpan(
                  child: TextWidget(
                text: currentState.videoData?.video?.date ?? '',
                color: Colors.grey,
                size: 12,
                fontWeight: FontWeight.w500,
              )),
              const WidgetSpan(child: SizedBox(width: 5)),
              TextSpan(
                  text: "More",
                  recognizer: TapGestureRecognizer()..onTap = () => [],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ))
            ])),
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeAnimation(
                  beginInterval: 0.3,
                  child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: ImageLoaderWidget(
                          url: currentState.videoData?.video?.channelThumb ?? '',
                          errorImageUrl: 'assets/custom_images/custom_user_image.png',
                        ),
                      )),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: FadeAnimation(
                  beginInterval: 0.3,
                  child: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: currentState.videoData?.video?.channelName ?? '-',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                        text: " • ${currentState.videoData?.video?.subscribeCount ?? '-'} ",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        )),
                    // WidgetSpan(
                    //     child: Icon(
                    //   Icons.check_circle,
                    //   color: Colors.red,
                    //   size: 13,
                    // )),
                    // const WidgetSpan(
                    //   child: SizedBox(width: 5),
                    // ),
                    // WidgetSpan(
                    //     child: TextWidget(
                    //   text: channel?.channelSnippet?.title ?? '-',
                    //   color: Colors.grey,
                    //   size: 15,
                    //   fontWeight: FontWeight.bold,
                    // )),
                    // const WidgetSpan(
                    //   child: SizedBox(width: 10),
                    // ),
                    // //
                    // WidgetSpan(
                    //     child: TextWidget(
                    //   text:
                    //       "${ViewFormatHelper.viewsFormatNumbers(int.tryParse("${currentState.video?.snippet?.channel?.channelSnippet?.channelStatistics?.subscriberCount}"))} ",
                    //   color: Colors.grey,
                    //   size: 13,
                    //   textAlign: TextAlign.start,
                    // ))
                  ])),
                )),
                const SizedBox(width: 5),
                PopScope(
                  canPop: false,
                  child: FadeAnimation(
                    beginInterval: 0.5,
                    child: Material(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          if (downloadingVideoCubit is VideoDownloadingErrorState) {
                            OpenDownloadingErrorPopup.downloadingErrorPopup(context);
                            return;
                          }
                          if (downloadingVideoCubit is VideoDownloadingLoadingState) {
                            OpenDisableDownloadingPopup.openDisableDownloadingPopup(context);
                            return;
                          }
                          if (currentState.loadingVideo) return;
                          OpenDownloadingVideoPopup.openDownloadingVideoPopup(context: context);
                        },
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15, bottom: 7, top: 7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (downloadingVideoCubit is VideoDownloadingGettingInfoState)
                                    const Row(
                                      children: [
                                        TextWidget(
                                          text: "Getting Information",
                                          color: Colors.white,
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                        ),
                                        SizedBox(width: 7),
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (downloadingVideoCubit is VideoDownloadingErrorState)
                                    const TextWidget(
                                      text: "Download error",
                                      color: Colors.white,
                                    )
                                  else if (downloadingVideoCubit is VideoDownloadingLoadingState)
                                    Row(
                                      children: [
                                        const TextWidget(
                                          text: "Downloading",
                                          color: Colors.white,
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                        ),
                                        const SizedBox(width: 7),
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                            value: downloadingVideoCubit
                                                .tempDownloadingVideoInfo?.downloadingProgress,
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (downloadingVideoCubit
                                      is VideoDownloadingGettingAudioInformationState)
                                    const Row(
                                      children: [
                                        TextWidget(
                                          text: "Processing sound",
                                          color: Colors.white,
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                        ),
                                        SizedBox(width: 7),
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (downloadingVideoCubit is VideoDownloadingAudioState)
                                    Row(
                                      children: [
                                        const TextWidget(
                                          text: "Processing sound",
                                          color: Colors.white,
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                        ),
                                        const SizedBox(width: 7),
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.blue,
                                            value: downloadingVideoCubit
                                                .tempDownloadingAudioInfo?.downloadingProgress,
                                          ),
                                        ),
                                      ],
                                    )
                                  else if (downloadingVideoCubit
                                      is VideoDownloadingSavingOnStorageState)
                                    const Row(
                                      children: [
                                        TextWidget(
                                          text: "A little more",
                                          color: Colors.white,
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.6,
                                        ),
                                        SizedBox(width: 7),
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    currentState.loadingVideo
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const FadeAnimation(
                                            beginInterval: 0.6,
                                            child: Row(
                                              children: [
                                                TextWidget(
                                                  text: "Download",
                                                  color: Colors.white,
                                                  size: 12,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.6,
                                                ),
                                                SizedBox(width: 7),
                                                Icon(
                                                  Icons.download,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                ],
                              )),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}
