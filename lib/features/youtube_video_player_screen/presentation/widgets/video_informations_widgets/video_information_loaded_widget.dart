import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/animations/fade_animation.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_states.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_states.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_disable_dowloading_popup.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_downloading_error_popup_info.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/usecases/open_popups/open_downloading_video_popup.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'downloaded_button_widget/another_video_downloading.dart';
import 'downloaded_button_widget/downloaded_button_widget.dart';

class VideoInformationLoadedWidget extends StatelessWidget {
  const VideoInformationLoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final youtubeCubit = context.watch<YoutubeVideoCubit>();
      final downloadingVideoCubit = context.watch<VideoDownloadingCubit>().state;
      final downloadingAudioCubit = context.watch<AudioDownloadingCubit>().state;

      var currentState = youtubeCubit.state.youtubeVideoStateModel;
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
              text: TextSpan(
                children: [
                  WidgetSpan(
                      child: TextWidget(
                    text: currentState.videoData?.video?.viewCount ?? '',
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

                  // for future development
                  // TextSpan(
                  //   text: "More",
                  //   recognizer: TapGestureRecognizer()..onTap = () => [],
                  //   style: const TextStyle(
                  //     color: Colors.black,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // )
                ],
              ),
            ),
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
                      text: TextSpan(
                        children: [
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (downloadingVideoCubit.isDownloading &&
                        downloadingVideoCubit.tempDownloadingVideoInfo?.mainVideoId !=
                            currentState.tempVideoId)
                      AnotherVideosDownloading(
                          onTap: () => context.read<YoutubeVideoCubit>().cancelTheVideo(),
                          downloadingProgress:
                              downloadingVideoCubit.tempDownloadingVideoInfo?.downloadingProgress ??
                                  0.0)
                    else if (downloadingAudioCubit.isAudioDownloading &&
                        downloadingAudioCubit.downloadingAudioInfo?.mainVideoId !=
                            currentState.tempVideoId)
                      AnotherVideosDownloading(
                          onTap: () => context.read<YoutubeVideoCubit>().cancelTheAudio(),
                          downloadingProgress:
                              downloadingAudioCubit.downloadingAudioInfo?.downloadingProgress ??
                                  0.0)
                    else
                      const SizedBox(),
                    if (downloadingVideoCubit.isDownloading)
                      DownloadedButtonWidget(
                        onTap: () {
                          if (downloadingVideoCubit is VideoDownloadingErrorState) {
                            OpenDownloadingErrorPopup.downloadingErrorPopup(
                              context,
                              title: Constants.videoDownloadedErrorTitleMessage,
                              content: Constants.videoDownloadedErrorContentMessage,
                            );
                            return;
                          }
                          if (downloadingVideoCubit is VideoDownloadingLoadingState) {
                            OpenDisableDownloadingPopup.openDisableDownloadingPopup(
                              context,
                              showOpenDownloadsPopup: true,
                            );
                            return;
                          }
                          if (currentState.loadingVideo) return;
                          OpenDownloadingVideoPopup.openDownloadingVideoPopup(context: context);
                        },
                        showGettingInfo:
                            downloadingVideoCubit is VideoDownloadingGettingInfoState &&
                                youtubeCubit
                                    .showInformationInButtonIfTheSameVideoIsDownloading(context),
                        showErrorInfo: downloadingVideoCubit is VideoDownloadingErrorState &&
                            youtubeCubit
                                .showInformationInButtonIfTheSameVideoIsDownloading(context),
                        showDownloading: downloadingVideoCubit is VideoDownloadingLoadingState &&
                            youtubeCubit
                                .showInformationInButtonIfTheSameVideoIsDownloading(context),
                        showTheSoundGettingInfo:
                            downloadingVideoCubit is VideoDownloadingGettingAudioInformationState &&
                                youtubeCubit
                                    .showInformationInButtonIfTheSameVideoIsDownloading(context),
                        showPrecessingTheSound:
                            downloadingVideoCubit is VideoDownloadingAudioState &&
                                youtubeCubit
                                    .showInformationInButtonIfTheSameVideoIsDownloading(context),
                        savingOnStorage:
                            downloadingVideoCubit is VideoDownloadingSavingOnStorageState &&
                                youtubeCubit
                                    .showInformationInButtonIfTheSameVideoIsDownloading(context),
                        loading: currentState.loadingVideo,
                        downloadingVideoProgress:
                            downloadingVideoCubit.tempDownloadingVideoInfo?.downloadingProgress ??
                                0.0,
                        downloadingAudioProgress:
                            downloadingVideoCubit.tempDownloadingAudioInfo?.downloadingProgress ??
                                0.0,
                      )
                    else
                      DownloadedButtonWidget(
                        onTap: () {
                          if (downloadingAudioCubit is AudioDownloadingErrorState) {
                            OpenDownloadingErrorPopup.downloadingErrorPopup(
                              context,
                              title: Constants.audioDownloadedErrorTitleMessage,
                              content: Constants.audioDownloadedErrorContentMessage,
                            );
                            return;
                          }
                          if (downloadingAudioCubit is AudioDownloadingState) {
                            OpenDisableDownloadingPopup.openDisableDownloadingPopup(
                              context,
                              showOpenDownloadsPopup: true,
                            );
                            return;
                          }
                          if (currentState.loadingVideo) return;
                          OpenDownloadingVideoPopup.openDownloadingVideoPopup(context: context);
                        },
                        showGettingInfo: downloadingAudioCubit is AudioGettingInformationState &&
                            youtubeCubit
                                .showInformationInButtonIfTheSameVideosAudioIsDownloading(context),
                        showErrorInfo: downloadingAudioCubit is AudioDownloadingErrorState &&
                            youtubeCubit
                                .showInformationInButtonIfTheSameVideosAudioIsDownloading(context),
                        showDownloading: downloadingAudioCubit is AudioDownloadingState &&
                            youtubeCubit
                                .showInformationInButtonIfTheSameVideosAudioIsDownloading(context),
                        showTheSoundGettingInfo: false,
                        showPrecessingTheSound: false,
                        savingOnStorage: downloadingAudioCubit is AudioSavingOnStorageState &&
                            youtubeCubit
                                .showInformationInButtonIfTheSameVideosAudioIsDownloading(context),
                        loading: currentState.loadingVideo,
                        downloadingVideoProgress:
                            downloadingAudioCubit.downloadingAudioInfo?.downloadingProgress ?? 0.0,
                        downloadingAudioProgress: 0.0,
                      ),
                  ],
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}
