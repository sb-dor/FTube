import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_information_cubit/video_information_states.dart';

class VideoInformationCubit extends Cubit<VideoInformationStates> {
  VideoInformationCubit() : super(LoadingVideoInformationState());

  void loadingVideoInformationState() => emit(LoadingVideoInformationState());

  void errorVideoInformationState() => emit(ErrorVideoInformationState());

  void loadedVideoInformationState() => emit(LoadedVideoInformationState());
}
