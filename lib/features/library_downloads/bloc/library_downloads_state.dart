import 'state_model/library_downloads_state_model.dart';

sealed class LibraryDownloadsState {
  LibraryDownloadsStateModel libraryDownloadsStateModel;

  LibraryDownloadsState({required this.libraryDownloadsStateModel});
}

final class LibraryDownloadsLoadingState extends LibraryDownloadsState {
  LibraryDownloadsLoadingState(
    LibraryDownloadsStateModel libraryDownloadsStateModel,
  ) : super(libraryDownloadsStateModel: libraryDownloadsStateModel);
}

final class LibraryDownloadsErrorState extends LibraryDownloadsState {
  LibraryDownloadsErrorState(
    LibraryDownloadsStateModel libraryDownloadsStateModel,
  ) : super(libraryDownloadsStateModel: libraryDownloadsStateModel);
}

final class LibraryDownloadsLoadedState extends LibraryDownloadsState {
  LibraryDownloadsLoadedState(
    LibraryDownloadsStateModel libraryDownloadsStateModel,
  ) : super(libraryDownloadsStateModel: libraryDownloadsStateModel);
}
