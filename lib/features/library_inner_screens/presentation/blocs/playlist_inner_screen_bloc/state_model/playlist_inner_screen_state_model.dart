import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/core/x_injection_containers/injection_container.dart';

class PlaylistInnerScreenStateModel {

  final ReusableGlobalFunctions _globalFunctions = locator<ReusableGlobalFunctions>();

  List<PlaylistModelDb> playlists = [];

  int page = 1;

  bool hasMore = true;

  void addPaginate({required List<PlaylistModelDb> videos, bool paginate = false}) {
    if (paginate) {
      playlists.addAll(videos);
    } else {
      playlists = videos;
    }

    page = _globalFunctions.checkIsListHasMorePageInt(list: videos, page: page);

    hasMore = _globalFunctions.checkIsListHasMorePageBool(list: videos);
  }
}
