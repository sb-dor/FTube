import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_details.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/video/data/video_repository.dart';

part 'video_controller.freezed.dart';

@freezed
sealed class VideoState with _$VideoState {
  const factory VideoState.initial() = Video$InitialState;

  const factory VideoState.inProgress() = Video$InProgressState;

  const factory VideoState.error({Object? error}) = Video$ErrorState;

  const factory VideoState.completed({required VideoDetails details}) = Video$CompletedState;
}

/// Loads a video's details and records it in the watch history.
final class VideoController extends StateController<VideoState> with SequentialControllerHandler {
  VideoController({required this._repository, super.initialState = const VideoState.initial()});

  final IVideoRepository _repository;

  /// Loads [videoId]. [opened] is the list item the user tapped (null for links); it is saved
  /// to history right away, otherwise the loaded details are.
  void load(String videoId, {VideoItem? opened}) => handle(
    () async {
      setState(const VideoState.inProgress());
      if (opened != null) await _repository.addToHistory(opened);
      final details = await _repository.details(videoId);
      setState(VideoState.completed(details: details));
      if (opened == null) {
        await _repository.addToHistory(
          VideoItem(
            id: details.id,
            title: details.title,
            channelName: details.channelName,
            channelId: details.channelId,
            channelAvatarUrl: details.channelAvatarUrl,
            viewsText: details.viewsText,
            publishedText: details.publishedText,
          ),
        );
      }
    },
    error: (error, stackTrace) async => setState(VideoState.error(error: error)),
    name: 'load',
  );
}
