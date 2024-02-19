import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/impl/library_create_playlist_locally/library_create_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/impl/library_get_playlist_locally/library_get_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/features/library_screen/data/repository/library_screen_repository_impl.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

abstract class LibraryInj {
  static Future<void> libraryInj() async {
    await _libraryLocalInj();
  }

  static Future<void> _libraryLocalInj() async {
    locator.registerLazySingleton<LibraryCreatePlaylistDataSource>(
      () => LibraryCreatePlaylistLocally(),
    );

    locator.registerLazySingleton<LibraryGetPlaylistDataSource>(
      () => LibraryGetPlaylistLocally(),
    );

    locator.registerLazySingleton<LibraryScreenRepository>(
      () => LibraryScreenRepositoryImpl(
        locator<LibraryCreatePlaylistDataSource>(),
        locator<LibraryGetPlaylistDataSource>(),
      ),
    );
  }
}
