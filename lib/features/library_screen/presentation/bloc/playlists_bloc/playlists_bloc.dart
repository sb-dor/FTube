import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/features/library_screen/domain/usecases/create_playlist.dart';
import 'package:youtube/features/library_screen/domain/usecases/get_playlists.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/state_model/playlists_state_model.dart';
import 'playlists_event.dart';
import 'playlists_state.dart';

class PlaylistsBloc extends Bloc<PlaylistsEvent, PlaylistsStates> {
  late PlayListsStateModel _currentState;
  late GetPlaylist _getPlaylist;
  late CreatePlaylist _createPlaylist;
  final LibraryScreenRepository _libraryScreenRepository;

  PlaylistsBloc(this._libraryScreenRepository)
      : super(LoadingPlaylistsState(PlayListsStateModel())) {
    //
    _currentState = state.playListsStateModel;
    _getPlaylist = GetPlaylist(_libraryScreenRepository);
    _createPlaylist = CreatePlaylist(_libraryScreenRepository);

    //
    on<GetPlaylistsEvent>(_getPlaylistsEvent);

    //
    on<DeletePlaylistEvent>(_deletePlaylistEvent);

    //
    on<CreatePlaylistEvent>(_createPlaylistEvent);
  }

  void _getPlaylistsEvent(
    GetPlaylistsEvent event,
    Emitter<PlaylistsStates> emit,
  ) async {
    emit(LoadingPlaylistsState(_currentState));

    final data = await _getPlaylist.getPlaylist();

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
  ) async =>
      await _createPlaylist.createPlaylist(event.name);
}
