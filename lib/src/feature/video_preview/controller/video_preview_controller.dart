import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video_preview/data/video_preview_repository.dart';

part 'video_preview_controller.freezed.dart';

@freezed
sealed class VideoPreviewState with _$VideoPreviewState {
  const factory VideoPreviewState.idle() = VideoPreview$IdleState;

  const factory VideoPreviewState.inProgress() = VideoPreview$InProgressState;

  const factory VideoPreviewState.error({Object? error}) = VideoPreview$ErrorState;

  const factory VideoPreviewState.ready({required StreamSource source}) = VideoPreview$ReadyState;
}

/// Resolves the stream for a card's hold-to-preview.
final class VideoPreviewController extends StateController<VideoPreviewState>
    with DroppableControllerHandler {
  VideoPreviewController({
    required this._repository,
    super.initialState = const VideoPreviewState.idle(),
  });

  final IVideoPreviewRepository _repository;

  void load(String videoId) => handle(
    () async {
      setState(const VideoPreviewState.inProgress());
      final source = await _repository.previewSource(videoId);
      setState(
        source == null ? const VideoPreviewState.error() : VideoPreviewState.ready(source: source),
      );
    },
    error: (error, stackTrace) async => setState(VideoPreviewState.error(error: error)),
    name: 'load',
  );

  void stop() => setState(const VideoPreviewState.idle());
}
