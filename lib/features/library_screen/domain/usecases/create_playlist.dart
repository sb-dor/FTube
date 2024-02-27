import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class CreatePlaylist {
  final LibraryScreenRepository _libraryScreenRepository;

  CreatePlaylist(this._libraryScreenRepository);

  Future<void> createPlaylist(String name) => _libraryScreenRepository.createPlayList(name);
}
