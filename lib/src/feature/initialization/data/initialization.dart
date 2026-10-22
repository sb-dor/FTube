import 'package:control/control.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/constant/firebase_options.dart';
import 'package:youtube/src/common/controller/controller_observer.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/download/media_muxer.dart';
import 'package:youtube/src/common/download/ranged_downloader.dart';
import 'package:youtube/src/common/js/js_runtime.dart';
import 'package:youtube/src/common/utils/analytics.dart';
import 'package:youtube/src/common/utils/app_language.dart';
import 'package:youtube/src/common/utils/error_util/error_util.dart';
import 'package:youtube/src/common/utils/platform_http_client.dart';
import 'package:youtube/src/common/youtube/challenge_solver.dart';
import 'package:youtube/src/common/youtube/po_token/po_token_generator.dart';
import 'package:youtube/src/common/youtube/youtube_client.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';
import 'package:youtube/src/feature/initialization/models/dependencies.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/data/device_media_store.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Initializes the app and its [Dependencies].
Future<void> $initializeApp({
  required Future<void> Function(Dependencies dependencies) onSuccess,
  required Future<void> Function(Object error, StackTrace stackTrace) onError,
}) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    Controller.observer = const ControllerObserver();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    ErrorUtil.init();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await BackgroundAudio.initialize();
    final sharedPreferences = await SharedPreferences.getInstance();
    final httpClient = createPlatformHttpClient();
    final database = AppDatabase.defaults();
    final youtubeExplode = YoutubeExplode();
    final botGuardRuntime = JsRuntime(name: 'botguard');
    final solverRuntime = JsRuntime(name: 'solver');
    final poTokenGenerator = PoTokenGenerator(
      httpClient: httpClient,
      runtime: botGuardRuntime,
      preferences: sharedPreferences,
    );
    final challengeSolver = WebViewChallengeSolver(runtime: solverRuntime);
    final streamsClient = YoutubeStreamsClient(
      httpClient: httpClient,
      youtubeExplode: youtubeExplode,
      poTokens: poTokenGenerator,
      solver: challengeSolver,
    );
    final videoDownloadRepository = VideoDownloadRepositoryImpl(
      streamsClient: streamsClient,
      downloader: RangedDownloader(createClient: createPlatformHttpClient),
      muxer: const FfmpegMediaMuxer(),
      mediaStore: const DeviceMediaStoreImpl(),
      database: database,
      temporaryDirectory: getTemporaryDirectory,
    );
    final dependencies = Dependencies()
      ..sharedPreferences = sharedPreferences
      ..database = database
      ..httpClient = httpClient
      ..youtubeClient = YoutubeClient(httpClient: httpClient, language: appLanguage)
      ..youtubeExplode = youtubeExplode
      ..analytics = FirebaseAnalyticsImpl(analytics: FirebaseAnalytics.instance)
      ..backgroundAudio = BackgroundAudio(player: AudioPlayer())
      ..botGuardRuntime = botGuardRuntime
      ..solverRuntime = solverRuntime
      ..poTokenGenerator = poTokenGenerator
      ..challengeSolver = challengeSolver
      ..youtubeStreamsClient = streamsClient
      ..videoDownloadRepository = videoDownloadRepository
      ..videoDownloadController = VideoDownloadController(repository: videoDownloadRepository);
    await onSuccess(dependencies);
  } on Object catch (error, stackTrace) {
    await onError(error, stackTrace);
  }
}
