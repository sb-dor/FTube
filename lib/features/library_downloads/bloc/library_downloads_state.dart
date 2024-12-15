import 'state_model/library_downloads_state_model.dart';

abstract class LibraryDownloadsState {
  LibraryDownloadsStateModel libraryDownloadsStateModel;

  LibraryDownloadsState({required this.libraryDownloadsStateModel});
}

class LibraryDownloadsLoadingState extends LibraryDownloadsState {
  LibraryDownloadsLoadingState(LibraryDownloadsStateModel libraryDownloadsStateModel)
      : super(libraryDownloadsStateModel: libraryDownloadsStateModel);
}

class LibraryDownloadsErrorState extends LibraryDownloadsState {
  LibraryDownloadsErrorState(LibraryDownloadsStateModel libraryDownloadsStateModel)
      : super(libraryDownloadsStateModel: libraryDownloadsStateModel);
}

class LibraryDownloadsLoadedState extends LibraryDownloadsState {
  LibraryDownloadsLoadedState(LibraryDownloadsStateModel libraryDownloadsStateModel)
      : super(libraryDownloadsStateModel: libraryDownloadsStateModel);
}
