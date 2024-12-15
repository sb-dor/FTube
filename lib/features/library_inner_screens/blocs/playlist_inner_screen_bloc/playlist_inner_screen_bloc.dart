import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository.dart';
import 'playlist_inner_screen_event.dart';
import 'playlist_inner_screen_state.dart';
import 'state_model/playlist_inner_screen_state_model.dart';

class PlaylistInnerScreenBloc extends Bloc<PlaylistInnerScreenEvent, PlaylistInnerScreenState> {
  final PlaylistInnerScreenRepository _playlistInnerScreenRepository;
  late PlaylistInnerScreenStateModel _currentState;

  //

  PlaylistInnerScreenBloc(
    this._playlistInnerScreenRepository,
  ) : super(LoadingPlaylistInnerState(PlaylistInnerScreenStateModel())) {
    _currentState = state.playlistInnerScreenStateModel;
    //
    //
    on<RefreshInnerPlaylistScreen>(_refreshInnerPlaylistScreen);

    //
    on<PaginateInnerPlaylistScreen>(_paginateInnerPlaylistScreen);
  }

  void _refreshInnerPlaylistScreen(
    RefreshInnerPlaylistScreen event,
    Emitter<PlaylistInnerScreenState> emit,
  ) async {
    emit(LoadingPlaylistInnerState(_currentState));

    final data = await _playlistInnerScreenRepository.getPlaylists();

    final checkForLikes = await _playlistInnerScreenRepository.getLikedVideos();

    if (checkForLikes.isNotEmpty) {
      data.insert(
        0,
        PlaylistModelDb(
          id: 0,
          name: "Liked Videos",
          videos: checkForLikes.map((e) => PlaylistVideosModelDb.fromEntity(e)!).toList(),
        ),
      );
    }

    _currentState.addPaginate(videos: data);

    emit(LoadedPlaylistInnerState(_currentState));
  }

  void _paginateInnerPlaylistScreen(
    PaginateInnerPlaylistScreen event,
    Emitter<PlaylistInnerScreenState> emit,
  ) async {
    final data = await _playlistInnerScreenRepository.getPlaylists(
      currentListLength: _currentState.playlists.length,
    );

    _currentState.addPaginate(videos: data, paginate: true);

    _emitter(emit);
  }

  void _emitter(Emitter<PlaylistInnerScreenState> emit) {
    if (state is LoadingPlaylistInnerState) {
      emit(LoadingPlaylistInnerState(_currentState));
    } else if (state is ErrorPlaylistInnerState) {
      emit(ErrorPlaylistInnerState(_currentState));
    } else if (state is LoadedPlaylistInnerState) {
      emit(LoadedPlaylistInnerState(_currentState));
    }
  }
}
