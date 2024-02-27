import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/impl/library_create_playlist_locally/library_create_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/impl/library_get_history_locally/library_get_history_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/library_get_history_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/impl/library_get_playlist_locally/library_get_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/impl/library_save_in_history_locally/library_save_in_history_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/library_save_in_history_data_source.dart';
import 'package:youtube/features/library_screen/data/repository/library_screen_repository_impl.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

abstract class LibraryInj {
  static Future<void> libraryInj() async {
    await _libraryLocalInj();
    // await _libraryFirebaseInj();

    //
    await _blocInit();
  }

  static Future<void> _libraryLocalInj() async {
    // registrations
    locator.registerLazySingleton<LibraryCreatePlaylistDataSource>(
      () => LibraryCreatePlaylistLocally(),
    );

    locator.registerLazySingleton<LibraryGetPlaylistDataSource>(
      () => LibraryGetPlaylistLocally(),
    );

    locator.registerLazySingleton<LibraryGetHistoryDataSource>(
      () => LibraryGetHistoryLocally(),
    );

    locator.registerLazySingleton<LibrarySaveInHistoryDataSource>(
      () => LibrarySaveInHistoryLocally(),
    );

    locator.registerLazySingleton<LibraryScreenRepository>(
      () => LibraryScreenRepositoryImpl(
          locator<LibraryCreatePlaylistDataSource>(),
          locator<LibraryGetPlaylistDataSource>(),
          locator<LibraryGetHistoryDataSource>(),
          locator<LibrarySaveInHistoryDataSource>()),
    );
  }

  static _libraryFirebaseInj() {}

  static Future<void> _blocInit() async {
    locator.registerFactory<HistoryBloc>(
      () => HistoryBloc(locator<LibraryScreenRepository>()),
    );

    locator.registerFactory<PlaylistsBloc>(
      () => PlaylistsBloc(locator<LibraryScreenRepository>()),
    );
  }
}
