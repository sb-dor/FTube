import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_states.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/downloading_video_info.dart';

class VideoDownloadingCubit extends Cubit<VideoDownloadingStates> {
  VideoDownloadingCubit() : super(VideoDownloadingLoadedState());

  void videoDownloadingGettingInfoState() => emit(
      VideoDownloadingGettingInfoState(tempDownloadingVideoInfo: state.tempDownloadingVideoInfo));

  void videoDownloadingLoadingState() =>
      emit(VideoDownloadingLoadingState(tempDownloadingVideoInfo: state.tempDownloadingVideoInfo));

  void videoDownloadingErrorState() =>
      emit(VideoDownloadingErrorState(tempDownloadingVideoInfo: state.tempDownloadingVideoInfo));

  void videoDownloadingLoadedState() =>
      emit(VideoDownloadingLoadedState(tempDownloadingVideoInfo: state.tempDownloadingVideoInfo));
}
