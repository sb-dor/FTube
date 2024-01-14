import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/similar_videos_cubit/similar_videos_states.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class SimilarVideosCubit extends Cubit<SimilarVideosStates> {
  List<Video> sameVideos = [];

  SimilarVideosCubit() : super(LoadingSimilarVideosState(data: <Video>[]));

  void loadingSimilarVideosState() => emit(LoadingSimilarVideosState());

  void errorSimilarVideosState() => emit(ErrorSimilarVideosState());

  void loadedSimilarVideosState() => emit(LoadedSimilarVideosState());
}
