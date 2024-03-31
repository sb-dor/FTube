import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/features/library_downloads/domain/repository/library_downloads_repository.dart';
import 'package:youtube/features/library_downloads/domain/usecases/get_downloads_usecase/get_downloads_usecase.dart';
import 'library_downloads_event.dart';
import 'library_downloads_state.dart';
import 'state_model/library_downloads_state_model.dart';

class LibraryDownloadsBloc extends Bloc<LibraryDownloadsEvent, LibraryDownloadsState> {
  final LibraryDownloadsRepository _libraryDownloadsRepository;
  late LibraryDownloadsStateModel _currentState;
  late GetDownloadsUseCase _getDownloadsUseCase;

  LibraryDownloadsBloc(this._libraryDownloadsRepository)
      : super(LibraryDownloadsLoadingState(LibraryDownloadsStateModel())) {
    _currentState = state.libraryDownloadsStateModel;
    _getDownloadsUseCase = GetDownloadsUseCase(_libraryDownloadsRepository);
    //
    //
    on<InitLibraryDownloadsEvent>(_initLibraryDownloadsEvent);

    //

    //
  }

  void _initLibraryDownloadsEvent(
    InitLibraryDownloadsEvent event,
    Emitter<LibraryDownloadsState> emit,
  ) async {
    emit(LibraryDownloadsLoadingState(_currentState));
    _currentState.files = await _getDownloadsUseCase.loadDownloadFiles();
    emit(LibraryDownloadsLoadedState(_currentState));
  }

  void _emitter(Emitter<LibraryDownloadsState> emit) {
    if (state is LibraryDownloadsLoadingState) {
      emit(LibraryDownloadsLoadingState(_currentState));
    } else if (state is LibraryDownloadsErrorState) {
      emit(LibraryDownloadsErrorState(_currentState));
    } else if (state is LibraryDownloadsLoadedState) {
      emit(LibraryDownloadsLoadedState(_currentState));
    }
  }
}
