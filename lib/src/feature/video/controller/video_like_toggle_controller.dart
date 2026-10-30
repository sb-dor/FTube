import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';

part 'video_like_toggle_controller.freezed.dart';

@freezed
sealed class VideoLikeToggleState with _$VideoLikeToggleState {
  const factory VideoLikeToggleState.initial() = VideoLikeToggle$InitialState;

  const factory VideoLikeToggleState.inProgress() = VideoLikeToggle$InProgressState;

  const factory VideoLikeToggleState.error({Object? error}) = VideoLikeToggle$ErrorState;

  const factory VideoLikeToggleState.completed({required bool liked}) =
      VideoLikeToggle$CompletedState;
}

/// Likes or unlikes the video. Droppable, so repeated taps while saving are ignored.
final class VideoLikeToggleController extends StateController<VideoLikeToggleState>
    with DroppableControllerHandler {
  VideoLikeToggleController({
    required this._videoLibraryRepository,
    super.initialState = const VideoLikeToggleState.initial(),
  });

  final IVideoLibraryRepository _videoLibraryRepository;

  void setLiked(VideoItem video, {required bool liked}) => handle(
    () async {
      setState(const VideoLikeToggleState.inProgress());
      await _videoLibraryRepository.setLiked(video, liked: liked);
      setState(VideoLikeToggleState.completed(liked: liked));
    },
    error: (error, stackTrace) async => setState(VideoLikeToggleState.error(error: error)),
    name: 'setLiked',
  );
}
