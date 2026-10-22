import 'package:flutter/material.dart';
import 'package:youtube/src/common/js/js_runtime.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/youtube_link.dart';
import 'package:youtube/src/feature/home/widgets/home_config_widget.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/mini_player/widgets/mini_player_config_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';
import 'package:youtube/src/feature/video_download/widgets/video_download_status_listener.dart';

/// Root widget. Opens YouTube links the app is launched with or receives while running.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // BotGuard attestation takes a few seconds; do it before the first video is opened.
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) DependenciesScope.of(context).poTokenGenerator.warmUp();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) async {
    final videoId = _videoIdFromRoute(routeInformation.uri);
    if (videoId == null) return false;
    _openVideo(videoId);
    return true;
  }

  List<Route<Object?>> _initialRoutes(String initialRoute) {
    final videoId = _videoIdFromRoute(Uri.parse(initialRoute));
    if (videoId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openVideo(videoId));
    }
    return [MaterialPageRoute<void>(builder: (_) => const HomeConfigWidget())];
  }

  String? _videoIdFromRoute(Uri uri) {
    if (uri.path.isEmpty || uri.path == '/') return null;
    final link = uri.hasScheme ? uri : Uri.https('www.youtube.com', uri.path, uri.queryParameters);
    return videoIdFromLink(link.toString());
  }

  void _openVideo(String videoId) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;
    VideoConfigWidget.openById(context, videoId: videoId);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: _navigatorKey,
    scaffoldMessengerKey: _messengerKey,
    onGenerateTitle: (context) => Localization.of(context).appTitle,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(),
    localizationsDelegates: Localization.localizationsDelegates,
    supportedLocales: Localization.supportedLocales,
    // Russian on Russian devices, English otherwise.
    localeResolutionCallback: (locale, supported) => supported.firstWhere(
      (l) => l.languageCode == locale?.languageCode,
      orElse: () => supported.first,
    ),
    builder: (context, child) => JsRuntimeHost(
      runtimes: [
        DependenciesScope.of(context).botGuardRuntime,
        DependenciesScope.of(context).solverRuntime,
      ],
      child: VideoDownloadStatusListener(
        messengerKey: _messengerKey,
        child: MediaQuery(
          // Layouts are sized for the default text scale, as before the rewrite.
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: MiniPlayerConfigWidget(
            onOpen: (session) {
              final context = _navigatorKey.currentContext;
              if (context == null) return;
              VideoConfigWidget.open(context, video: session.video, startAt: session.position);
            },
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    ),
    onGenerateInitialRoutes: _initialRoutes,
    onGenerateRoute: (settings) =>
        MaterialPageRoute<void>(settings: settings, builder: (_) => const HomeConfigWidget()),
  );
}
