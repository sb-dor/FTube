import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';

class PlayListsStateModel {
  final _globalFunctions = locator<ReusableGlobalFunctions>();

  List<PlaylistModelDb> playlist = [];

  int page = 1;

  bool hasMore = false;

  PlaylistModelDb? tempSelectedPlaylist;

  void addPaginate({required List<PlaylistModelDb> list, bool paginate = false}) {
    if (paginate) {
      playlist.addAll(list);
    } else {
      playlist = list;
    }

    page = _globalFunctions.checkIsListHasMorePageInt(list: list, page: page);

    hasMore = _globalFunctions.checkIsListHasMorePageBool(list: list);
  }
}
