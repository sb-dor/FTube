import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';
import 'package:youtube/features/library_inner_screens/domain/usecases/playlist_liked_videos_usecase/playlist_liked_videos_usecase.dart';
import 'package:youtube/features/library_inner_screens/domain/usecases/playlist_videos_inner_screen_usecase/playlist_videos_inner_screen_usecase.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/state_model/playlist_videos_inner_screen_state_model.dart';

import 'playlist_videos_inner_screen_event.dart';
import 'playlist_videos_inner_screen_state.dart';

class PlaylistVideosInnerScreenBloc
    extends Bloc<PlaylistVideosInnerScreenEvent, PlaylistVideosInnerScreenState> {
  final PlaylistInnerScreenRepository _playlistInnerScreenRepository;
  late PlaylistVideosInnerScreenUsecase _playlistVideosInnerScreenUsecase;
  late PlaylistLikedVideosUseCase _playlistLikedVideosUseCase;
  late PlaylistVideosInnerScreenStateModel _currentState;

  PlaylistVideosInnerScreenBloc(this._playlistInnerScreenRepository)
      : super(LoadingPlaylistVideosInnerScreenState(PlaylistVideosInnerScreenStateModel())) {
    _playlistVideosInnerScreenUsecase = PlaylistVideosInnerScreenUsecase(
      _playlistInnerScreenRepository,
    );

    _playlistLikedVideosUseCase = PlaylistLikedVideosUseCase(
      _playlistInnerScreenRepository,
    );

    _currentState = state.playlistVideosInnerScreenStateModel;
    //
    on<RefreshPlaylistVideosInnerScreenEvent>(_refreshPlaylistVideosInnerScreenEvent);

    on<PaginatePlaylistVideosInnerScreenEvent>(_paginatePlaylistVideosInnerScreenEvent);
  }

  void _refreshPlaylistVideosInnerScreenEvent(
    RefreshPlaylistVideosInnerScreenEvent event,
    Emitter<PlaylistVideosInnerScreenState> emit,
  ) async {
    emit(LoadingPlaylistVideosInnerScreenState(_currentState));

    List<BaseVideoModelDb> data = [];

    // playlist with id => 0 is liked videos playlist
    if (event.playlistModelDb?.id == 0) {
      data = await _playlistLikedVideosUseCase.getLikedVideos();
    } else {
      data = await _playlistVideosInnerScreenUsecase.getPlaylistVideos(
        playlistModelDb: event.playlistModelDb,
      );
    }

    _currentState.addPaginate(videos: data);

    emit(LoadedPlaylistVideosInnerScreenState(_currentState));
  }

  void _paginatePlaylistVideosInnerScreenEvent(
    PaginatePlaylistVideosInnerScreenEvent event,
    Emitter<PlaylistVideosInnerScreenState> emit,
  ) async {
    List<BaseVideoModelDb> data = [];

    // playlist with id => 0 is liked videos playlist
    if (event.playlistModelDb?.id == 0) {
      data = await _playlistLikedVideosUseCase.getLikedVideos(
        currentListLength: _currentState.playlistVideos.length,
      );
    } else {
      data = await _playlistVideosInnerScreenUsecase.getPlaylistVideos(
        currentListLength: _currentState.playlistVideos.length,
        playlistModelDb: event.playlistModelDb,
      );
    }

    _currentState.addPaginate(videos: data, paginate: true);

    _emitter(emit);
  }

  void _emitter(Emitter<PlaylistVideosInnerScreenState> emit) {
    if (state is LoadingPlaylistVideosInnerScreenState) {
      emit(LoadingPlaylistVideosInnerScreenState(_currentState));
    } else if (state is ErrorPlaylistVideosInnerScreenState) {
      emit(ErrorPlaylistVideosInnerScreenState(_currentState));
    } else if (state is LoadedPlaylistVideosInnerScreenState) {
      emit(LoadedPlaylistVideosInnerScreenState(_currentState));
    }
  }
}
