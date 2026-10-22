import 'dart:async';

import 'package:control/control.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';

/// Whether the video is saved in any playlist.
final class VideoBookmarkController extends StateController<bool> with SequentialControllerHandler {
  VideoBookmarkController({required this._repository, super.initialState = false});

  final IVideoLibraryRepository _repository;
  StreamSubscription<bool>? _subscription;

  void watch(String videoId) {
    _subscription?.cancel().ignore();
    _subscription = _repository.watchInPlaylist(videoId).listen(setState, onError: onError);
  }

  @override
  void dispose() {
    _subscription?.cancel().ignore();
    super.dispose();
  }
}
