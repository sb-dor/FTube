import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/preview_hint/controller/preview_hint_controller.dart';
import 'package:youtube/src/feature/preview_hint/data/preview_hint_repository.dart';
import 'package:youtube/src/feature/preview_hint/widgets/mobile/preview_hint_mobile_widget.dart';

/// Provides [PreviewHintConfigWidgetState] to the hint overlay.
class PreviewHintConfigInhWidget extends InheritedWidget {
  const PreviewHintConfigInhWidget({required this.state, required super.child, super.key});

  final PreviewHintConfigWidgetState state;

  static PreviewHintConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PreviewHintConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PreviewHintConfigInhWidget was not found in the widget tree');
    return (widget! as PreviewHintConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PreviewHintConfigInhWidget oldWidget) => false;
}

/// One-time "hold inside this square to start preview" hint.
///
/// Lives in an invisible root [OverlayEntry] while it checks the persisted flag; when the hint
/// has not been seen yet it opens [PreviewHintMobileWidget] as a transparent dialog route (so the
/// back button closes it) and persists the flag once that route is closed in any way.
class PreviewHintConfigWidget extends StatefulWidget {
  const PreviewHintConfigWidget({required this.target, required this.onFinished, super.key});

  static bool _isActive = false;

  /// Shows the hint over [target] (global coordinates, e.g. the first card's preview zone) unless
  /// the user has already seen it. Completes when the hint is closed or was not needed.
  static Future<void> showIfNeeded(BuildContext context, {required Rect target}) async {
    if (_isActive) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    _isActive = true;
    final finished = Completer<void>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => PreviewHintConfigWidget(
        target: target,
        onFinished: () {
          if (finished.isCompleted) return;
          entry
            ..remove()
            ..dispose();
          finished.complete();
        },
      ),
    );
    overlay.insert(entry);
    try {
      await finished.future;
    } finally {
      _isActive = false;
    }
  }

  /// Area to highlight, in global coordinates.
  final Rect target;

  /// Called once the hint was dismissed or turned out not to be needed.
  final VoidCallback onFinished;

  @override
  State<PreviewHintConfigWidget> createState() => PreviewHintConfigWidgetState();
}

class PreviewHintConfigWidgetState extends State<PreviewHintConfigWidget> {
  late final PreviewHintController previewHintController;
  bool _isHintOpen = false;

  Rect get target => widget.target;

  @override
  void initState() {
    super.initState();
    previewHintController = PreviewHintController(
      previewHintRepository: PreviewHintRepositoryImpl(
        sharedPreferences: DependenciesScope.of(context).sharedPreferences,
      ),
    )..addListener(_onStateChanged);
    previewHintController.check();
  }

  @override
  void dispose() {
    previewHintController
      ..removeListener(_onStateChanged)
      ..dispose();
    super.dispose();
  }

  /// Runs inside the controller's handler zone, so UI work is deferred to the next frame.
  void _onStateChanged() {
    switch (previewHintController.state) {
      case PreviewHint$PendingState():
        if (_isHintOpen) return;
        _isHintOpen = true;
        SchedulerBinding.instance
          ..addPostFrameCallback((_) => _openHint())
          ..ensureVisualUpdate();
      case PreviewHint$ShownState() || PreviewHint$ErrorState():
        if (_isHintOpen) return;
        SchedulerBinding.instance
          ..addPostFrameCallback((_) => widget.onFinished())
          ..ensureVisualUpdate();
      case PreviewHint$InitialState():
        break;
    }
  }

  Future<void> _openHint() async {
    if (!mounted) return;
    await showGeneralDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      pageBuilder: (context, _, _) =>
          PreviewHintConfigInhWidget(state: this, child: const PreviewHintMobileWidget()),
    );
    _isHintOpen = false;
    if (!mounted) return;
    // Closed by the square, the Close button, a swipe or the back button: never show it again.
    previewHintController.markShown();
  }

  /// The hint is a route on the root overlay, so this host renders nothing and lets taps through.
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
