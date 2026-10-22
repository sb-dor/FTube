import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/js/js_runtime.dart';
import 'package:youtube/src/common/utils/analytics.dart';
import 'package:youtube/src/common/youtube/challenge_solver.dart';
import 'package:youtube/src/common/youtube/po_token/po_token_generator.dart';
import 'package:youtube/src/common/youtube/youtube_client.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';
import 'package:youtube/src/feature/video_preview/widgets/controllers/video_preview_coordinator.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// {@template dependencies}
/// Application-wide dependencies.
/// {@endtemplate}
class Dependencies {
  /// {@macro dependencies}
  Dependencies();

  late final SharedPreferences sharedPreferences;

  /// History, likes, playlists and downloaded files.
  late final AppDatabase database;

  /// Shared HTTP client for YouTube pages.
  late final http.Client httpClient;

  /// Search, watch-page details, related videos, suggestions.
  late final YoutubeClient youtubeClient;

  /// Stream manifests for playback and downloads.
  late final YoutubeExplode youtubeExplode;

  /// Hidden browser pages, mounted by the App: BotGuard switches its page to Trusted Types,
  /// which would block the challenge solver, so each has its own.
  late final JsRuntime botGuardRuntime;

  late final JsRuntime solverRuntime;

  late final PoTokenGenerator poTokenGenerator;

  late final WebViewChallengeSolver challengeSolver;

  /// Download streams from every YouTube client that serves them.
  late final YoutubeStreamsClient youtubeStreamsClient;

  late final IAnalytics analytics;

  /// The single background audio player.
  late final BackgroundAudio backgroundAudio;

  /// Stream downloads (options and the pipeline).
  late final IVideoDownloadRepository videoDownloadRepository;

  /// The app-wide running download.
  late final VideoDownloadController videoDownloadController;

  /// Lets only one list card preview at a time.
  final VideoPreviewCoordinator videoPreviewCoordinator = VideoPreviewCoordinator();

  /// Injects these dependencies into the widget tree.
  Widget inject({required Widget child, Key? key}) =>
      DependenciesScope(dependencies: this, key: key, child: child);
}
