import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_information_states.dart';

class VideoInformationCubit extends Cubit<VideoInformationStates> {
  VideoInformationCubit() : super(LoadingVideoInformationState());

  void loadingVideoInformationState() => emit(LoadingVideoInformationState());

  void errorVideoInformationState() => emit(ErrorVideoInformationState());

  void loadedVideoInformationState() => emit(LoadedVideoInformationState());
}
