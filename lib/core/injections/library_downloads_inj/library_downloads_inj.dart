import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/features/library_downloads/data/repository/library_downloads_repository_impl.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/get_downloaded_files_source.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/impl/get_downloaded_files_source_impl.dart';
import 'package:youtube/features/library_downloads/domain/repository/library_downloads_repository.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';

abstract class LibraryDownloadsInj {
  static Future<void> libraryDownloadsInj() async {
    //

    locator.registerFactory<LibraryDownloadsBloc>(
      () => LibraryDownloadsBloc(
        LibraryDownloadsRepositoryImpl(
          GetDownloadedFilesSourceImpl(),
        ),
      ),
    );
  }
}
