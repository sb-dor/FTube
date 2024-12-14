import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_downloads/data/repository/library_downloads_repository_impl.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/impl/get_downloaded_files_source_impl.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';

final class LibraryDownloadsBlocFactory implements Factory<LibraryDownloadsBloc> {
  final DbFloor _dbFloor;

  LibraryDownloadsBlocFactory(this._dbFloor);

  @override
  LibraryDownloadsBloc create() {
    final downloadedFileSource = GetDownloadedFilesSourceImpl(dbFloor: _dbFloor);

    final libraryDownloadsRepo = LibraryDownloadsRepositoryImpl(downloadedFileSource);

    return LibraryDownloadsBloc(libraryDownloadsRepo);
  }
}
