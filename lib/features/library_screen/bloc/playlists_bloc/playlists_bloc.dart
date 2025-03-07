import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'playlists_event.dart';
import 'playlists_state.dart';
import 'state_model/playlists_state_model.dart';

class PlaylistsBloc extends Bloc<PlaylistsEvent, PlaylistsStates> {
  late PlayListsStateModel _currentState;
  final LibraryScreenRepository _libraryScreenRepository;

  PlaylistsBloc(this._libraryScreenRepository)
    : super(LoadingPlaylistsState(PlayListsStateModel())) {
    //
    _currentState = state.playListsStateModel;

    //
    on<GetPlaylistsEvent>(_getPlaylistsEvent);

    //
    on<DeletePlaylistEvent>(_deletePlaylistEvent);

    //
    on<CreatePlaylistEvent>(_createPlaylistEvent);

    //
    on<SaveInPlaylistEvent>(_saveInPlaylistEvent);

    //
    on<ClearTempPlaylist>(_clearTempPlaylist);

    //
    on<SelectTempPlaylist>(_selectTempPlaylist);

    //
    on<CheckIsVideoInPlaylistEvent>(_checkIsVideoInPlaylistEvent);

    //
    on<GetLikedVideosEvent>(_getLikedVideosEvent);
  }

  void _getPlaylistsEvent(GetPlaylistsEvent event, Emitter<PlaylistsStates> emit) async {
    emit(LoadingPlaylistsState(_currentState));

    final data = await _libraryScreenRepository.getPlaylists();

    final likedVideos = await _libraryScreenRepository.getLikedVideo();

    if (likedVideos.isNotEmpty) {
      data.insert(
        0,
        PlaylistModelDb(
          id: 0,
          name: "Liked videos",
          videos: likedVideos.map((e) => PlaylistVideosModelDb.fromEntity(e)!).toList(),
        ),
      );
    }

    _currentState.addPaginate(list: data);

    emit(LoadedPlaylistsState(_currentState));
  }

  void _deletePlaylistEvent(DeletePlaylistEvent event, Emitter<PlaylistsStates> emit) async {}

  void _createPlaylistEvent(CreatePlaylistEvent event, Emitter<PlaylistsStates> emit) async {
    await _libraryScreenRepository.createPlayList(event.name);
    add(GetPlaylistsEvent());
  }

  void _saveInPlaylistEvent(SaveInPlaylistEvent event, Emitter<PlaylistsStates> emit) async {
    if (_currentState.tempSelectedPlaylist == null) return;
    await _libraryScreenRepository.saveInPlayList(
      event.videoModelDb,
      _currentState.tempSelectedPlaylist,
    );
    add(GetPlaylistsEvent());
  }

  void _clearTempPlaylist(ClearTempPlaylist event, Emitter<PlaylistsStates> emit) {
    _currentState.tempSelectedPlaylist = null;
    _emitter(emit);
  }

  void _selectTempPlaylist(SelectTempPlaylist event, Emitter<PlaylistsStates> emit) {
    if (_currentState.tempSelectedPlaylist?.id == event.playlistModelDb?.id) {
      _currentState.tempSelectedPlaylist = null;
    } else {
      _currentState.tempSelectedPlaylist = event.playlistModelDb;
    }
    _emitter(emit);
  }

  void _checkIsVideoInPlaylistEvent(
    CheckIsVideoInPlaylistEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {
    _currentState.tempSelectedPlaylist = await _libraryScreenRepository.videoPlaylist(
      event.baseVideoModelDb,
    );
    _emitter(emit);
  }

  void _getLikedVideosEvent(GetLikedVideosEvent event, Emitter<PlaylistsStates> emit) async {}

  void _emitter(Emitter<PlaylistsStates> emit) {
    if (state is LoadingPlaylistsState) {
      emit(LoadingPlaylistsState(_currentState));
    } else if (state is ErrorPlaylistsState) {
      emit(ErrorPlaylistsState(_currentState));
    } else if (state is LoadedPlaylistsState) {
      emit(LoadedPlaylistsState(_currentState));
    }
  }
}
