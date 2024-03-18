import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_downloads/domain/repository/library_downloads_repository.dart';
import 'library_downloads_event.dart';
import 'library_downloads_state.dart';

class LibraryDownloadsBloc extends Bloc<LibraryDownloadsEvent, LibraryDownloadsState> {
  final LibraryDownloadsRepository _libraryDownloadsRepository;

  LibraryDownloadsBloc(this._libraryDownloadsRepository) : super(LibraryDownloadsInitial()) {
    //
    //
    on<InitLibraryDownloadsEvent>(_initLibraryDownloadsEvent);
  }

  void _initLibraryDownloadsEvent(
    InitLibraryDownloadsEvent event,
    Emitter<LibraryDownloadsState> emit,
  ) {}
}
