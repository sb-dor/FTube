
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
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
    on<SaveAppStorageFileInGalleryEvent>(_saveAppStorageFileInGalleryEvent);
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

  void _saveAppStorageFileInGalleryEvent(
    SaveAppStorageFileInGalleryEvent event,
    Emitter<LibraryDownloadsState> emit,
  ) async {
    final type = _currentState.globalFunctions.fileExtensionName(event.baseDownloadedFileModel);
    try {
      if (type == 'mp4' && event.baseDownloadedFileModel?.downloadedPath != null) {
        bool access = await Gal.hasAccess();
        if (!access) access = await Gal.requestAccess();
        if (!access) return;
        await Gal.putVideo(event.baseDownloadedFileModel?.downloadedPath ?? '');
        _currentState.globalFunctions.showToast(
          msg: "Successfully saved in gallery!",
          textColor: Colors.white,
        );
      }
    } catch (e) {
      _currentState.globalFunctions.showToast(
        msg: "Something went wrong. Please try again",
        typeError: true,
        textColor: Colors.white,
      );
    }
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
