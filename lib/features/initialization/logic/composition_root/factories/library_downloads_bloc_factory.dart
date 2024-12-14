import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_downloads/data/repository/library_downloads_repository_impl.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/impl/get_downloaded_files_source_impl.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';

final class LibraryDownloadsBlocFactory implements Factory<LibraryDownloadsBloc> {
  @override
  LibraryDownloadsBloc create() {
    final downloadedFileSource = GetDownloadedFilesSourceImpl();

    final libraryDownloadsRepo = LibraryDownloadsRepositoryImpl(downloadedFileSource);

    return LibraryDownloadsBloc(libraryDownloadsRepo);
  }
}
