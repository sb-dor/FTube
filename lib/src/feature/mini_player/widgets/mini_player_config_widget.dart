import 'package:flutter/material.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';
import 'package:youtube/src/feature/mini_player/widgets/controllers/mini_player_data_controller.dart';
import 'package:youtube/src/feature/mini_player/widgets/mobile/mini_player_widget.dart';

/// Provides [MiniPlayerConfigWidgetState] to the app.
class MiniPlayerConfigInhWidget extends InheritedWidget {
  const MiniPlayerConfigInhWidget({required this.state, required super.child, super.key});

  final MiniPlayerConfigWidgetState state;

  static MiniPlayerConfigWidgetState? maybeOf(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<MiniPlayerConfigInhWidget>()?.widget
              as MiniPlayerConfigInhWidget?)
          ?.state;

  @override
  bool updateShouldNotify(covariant MiniPlayerConfigInhWidget oldWidget) => false;
}

/// Floats a small draggable player over the whole app after a video screen closes.
class MiniPlayerConfigWidget extends StatefulWidget {
  const MiniPlayerConfigWidget({required this.onOpen, required this.child, super.key});

  /// Opens the full video screen for a session (the user tapped "expand").
  final void Function(MiniPlayerSession session) onOpen;
  final Widget child;

  /// Continues [session] in the mini player.
  static void show(BuildContext context, MiniPlayerSession session) =>
      maybeOfState(context)?.miniPlayerDataController.show(session);

  /// Closes the mini player; returns what it was playing, with the current position.
  static MiniPlayerSession? close(BuildContext context) => maybeOfState(context)?.close();

  static MiniPlayerConfigWidgetState? maybeOfState(BuildContext context) =>
      MiniPlayerConfigInhWidget.maybeOf(context);

  @override
  State<MiniPlayerConfigWidget> createState() => MiniPlayerConfigWidgetState();
}

class MiniPlayerConfigWidgetState extends State<MiniPlayerConfigWidget> {
  late final MiniPlayerDataController miniPlayerDataController;

  /// Reports the playing position; set by the visible player.
  Duration Function()? positionReader;

  @override
  void initState() {
    super.initState();
    miniPlayerDataController = MiniPlayerDataController();
  }

  @override
  void dispose() {
    miniPlayerDataController.dispose();
    super.dispose();
  }

  MiniPlayerSession? close() => miniPlayerDataController.close(position: positionReader?.call());

  void expand() {
    final session = close();
    if (session != null) widget.onOpen(session);
  }

  @override
  Widget build(BuildContext context) => MiniPlayerConfigInhWidget(
    state: this,
    child: Stack(
      children: [
        Positioned.fill(child: widget.child),
        ListenableBuilder(
          listenable: miniPlayerDataController,
          builder: (context, _) => switch (miniPlayerDataController.session) {
            final session? => MiniPlayerWidget(key: ValueKey(session), session: session),
            null => const SizedBox.shrink(),
          },
        ),
      ],
    ),
  );
}
