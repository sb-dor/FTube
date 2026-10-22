import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/video/data/video_repository.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';

part 'video_streams_controller.freezed.dart';

@freezed
sealed class VideoStreamsState with _$VideoStreamsState {
  const factory VideoStreamsState.initial() = VideoStreams$InitialState;

  const factory VideoStreamsState.inProgress() = VideoStreams$InProgressState;

  const factory VideoStreamsState.error({Object? error}) = VideoStreams$ErrorState;

  const factory VideoStreamsState.completed({required VideoStreams streams}) =
      VideoStreams$CompletedState;
}

/// Resolves the playable streams of a video.
final class VideoStreamsController extends StateController<VideoStreamsState>
    with SequentialControllerHandler {
  VideoStreamsController({
    required this._repository,
    super.initialState = const VideoStreamsState.initial(),
  });

  final IVideoRepository _repository;

  void load(String videoId) => handle(
    () async {
      setState(const VideoStreamsState.inProgress());
      setState(VideoStreamsState.completed(streams: await _repository.streams(videoId)));
    },
    error: (error, stackTrace) async => setState(VideoStreamsState.error(error: error)),
    name: 'load',
  );
}
