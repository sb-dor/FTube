import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';

part 'download_options_controller.freezed.dart';

@freezed
sealed class DownloadOptionsState with _$DownloadOptionsState {
  const factory DownloadOptionsState.initial() = DownloadOptions$InitialState;

  const factory DownloadOptionsState.inProgress() = DownloadOptions$InProgressState;

  const factory DownloadOptionsState.error({Object? error}) = DownloadOptions$ErrorState;

  const factory DownloadOptionsState.completed({required DownloadOptions options}) =
      DownloadOptions$CompletedState;
}

/// Loads the qualities a video can be downloaded in.
final class DownloadOptionsController extends StateController<DownloadOptionsState>
    with SequentialControllerHandler {
  DownloadOptionsController({
    required this._repository,
    super.initialState = const DownloadOptionsState.initial(),
  });

  final IVideoDownloadRepository _repository;

  void load(String videoId) => handle(
    () async {
      setState(const DownloadOptionsState.inProgress());
      setState(DownloadOptionsState.completed(options: await _repository.options(videoId)));
    },
    error: (error, stackTrace) async => setState(DownloadOptionsState.error(error: error)),
    name: 'load',
  );
}
