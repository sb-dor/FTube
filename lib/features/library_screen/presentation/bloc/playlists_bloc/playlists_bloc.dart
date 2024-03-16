import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/features/library_screen/domain/usecases/create_playlist.dart';
import 'package:youtube/features/library_screen/domain/usecases/get_liked_videos.dart';
import 'package:youtube/features/library_screen/domain/usecases/get_playlists.dart';
import 'package:youtube/features/library_screen/domain/usecases/get_video_playlist.dart';
import 'package:youtube/features/library_screen/domain/usecases/save_in_playlist.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/state_model/playlists_state_model.dart';
import 'playlists_event.dart';
import 'playlists_state.dart';

class PlaylistsBloc extends Bloc<PlaylistsEvent, PlaylistsStates> {
  late PlayListsStateModel _currentState;
  late GetPlaylist _getPlaylist;
  late CreatePlaylist _createPlaylist;
  late SaveInPlaylist _saveInPlaylist;
  late GetVideoPlaylist _getVideoPlaylist;
  late GetLikedVideos _getLikedVideos;
  final LibraryScreenRepository _libraryScreenRepository;

  PlaylistsBloc(this._libraryScreenRepository)
      : super(LoadingPlaylistsState(PlayListsStateModel())) {
    //
    _currentState = state.playListsStateModel;
    _getPlaylist = GetPlaylist(_libraryScreenRepository);
    _createPlaylist = CreatePlaylist(_libraryScreenRepository);
    _saveInPlaylist = SaveInPlaylist(_libraryScreenRepository);
    _getVideoPlaylist = GetVideoPlaylist(_libraryScreenRepository);
    _getLikedVideos = GetLikedVideos(_libraryScreenRepository);

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

  void _getPlaylistsEvent(
    GetPlaylistsEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {
    emit(LoadingPlaylistsState(_currentState));

    final data = await _getPlaylist.getPlaylist();

    final likedVideos = await _getLikedVideos.getLikedVideos();

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

  void _deletePlaylistEvent(
    DeletePlaylistEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {}

  void _createPlaylistEvent(
    CreatePlaylistEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {
    await _createPlaylist.createPlaylist(event.name);
    add(GetPlaylistsEvent());
  }

  void _saveInPlaylistEvent(
    SaveInPlaylistEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {
    if (_currentState.tempSelectedPlaylist == null) return;
    await _saveInPlaylist.saveInPlaylist(event.videoModelDb, _currentState.tempSelectedPlaylist);
    add(GetPlaylistsEvent());
  }

  void _clearTempPlaylist(
    ClearTempPlaylist event,
    Emitter<PlaylistsStates> emit,
  ) {
    _currentState.tempSelectedPlaylist = null;
    _emitter(emit);
  }

  void _selectTempPlaylist(
    SelectTempPlaylist event,
    Emitter<PlaylistsStates> emit,
  ) {
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
    _currentState.tempSelectedPlaylist =
        await _getVideoPlaylist.videoPlaylist(event.baseVideoModelDb);
    _emitter(emit);
  }

  void _getLikedVideosEvent(
    GetLikedVideosEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {}

  void _emitter(Emitter<PlaylistsStates> emit) {
    if (state is LoadingPlaylistsState) {
      emit(LoadingPlaylistsState(_currentState));
    } else if (state is ErrorPlaylistsState) {
      emit(ErrorPlaylistsState(_currentState));
    } else if (state is LoadedPlaylistsState) {
      emit(ErrorPlaylistsState(_currentState));
    }
  }
}
