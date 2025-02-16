import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/top_overlay_feature/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/top_overlay_feature/bloc/top_overlay_feature_events.dart';
import 'package:youtube/features/top_overlay_feature/bloc/top_overlay_feature_states.dart';
import 'package:youtube/features/top_overlay_feature/view/overlay_opener/top_overlay_logic.dart';

class TopOverlayFeature extends StatelessWidget {
  final OverlayEntry overlayEntry;
  final String videoId;
  final Duration? position;

  const TopOverlayFeature({
    super.key,
    required this.overlayEntry,
    required this.videoId,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopOverlayFeatureBloc(),
      child: _TopOverlayFeatureUI(
        overlayEntry: overlayEntry,
        videoId: videoId,
        position: position,
      ),
    );
  }
}

class _TopOverlayFeatureUI extends StatefulWidget {
  final OverlayEntry overlayEntry;
  final String videoId;
  final Duration? position;

  const _TopOverlayFeatureUI({
    required this.overlayEntry,
    required this.videoId,
    required this.position,
  });

  @override
  State<_TopOverlayFeatureUI> createState() => _TopOverlayFeatureState();
}

class _TopOverlayFeatureState extends State<_TopOverlayFeatureUI> {
  static const double _containerWidth = 250;
  static const double _containerHeight = 150;
  double? maxX;
  double? maxY;

  Offset offset = const Offset(20, 40);

  @override
  void initState() {
    super.initState();
    // _subscription = FlutterOverlayWindow.overlayListener.listen((event) {
    context.read<TopOverlayFeatureBloc>().add(ConvertToLoadingState());
    //   // debugPrint"Current Event: $event | type: ${event.runtimeType}");
    //   if (event is! String) return;
    //   Map<String, dynamic> convertToJson = jsonDecode(event);
    //   if (!convertToJson.containsKey("url_for_run") || convertToJson['url_for_run'] == null) return;
    //   final String videoUrl = convertToJson['url_for_run'];
    context.read<TopOverlayFeatureBloc>().add(
          InitOverlayVideoController(
            widget.videoId,
            widget.position,
          ),
        );
    // });

    WidgetsBinding.instance.addPersistentFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      maxX = size.width - _containerWidth;
      maxY = size.height - _containerHeight;
    });
  }

  @override
  void dispose() {
    TopOverlayLogic.instance.removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopOverlayFeatureBloc, TopOverlayFeatureStates>(
      builder: (context, state) {
        final currentState = state.topOverlayFeatureStateModel;
        return DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
          ),
          child: GestureDetector(
            onTap: () {
              TopOverlayLogic.instance.removeOverlay();
            },
            onPanUpdate: (details) {
              final newOffset = offset + details.delta;

              // Clamp the new offset to keep the widget within the screen boundaries
              final clampedX = newOffset.dx.clamp(0.0, maxX ?? 0.0);
              final clampedY = newOffset.dy.clamp(0.0, maxY ?? 0.0);

              offset = Offset(clampedX, clampedY);
              widget.overlayEntry.markNeedsBuild();
              // setState(() {});
            },
            child: Stack(
              fit: StackFit.loose,
              children: [
                Positioned(
                  top: offset.dy,
                  left: offset.dx,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: show stop overlay
                            context
                                .read<TopOverlayFeatureBloc>()
                                .add(ShowAndHideButtonsOnClickEvent());
                          },
                          child: Container(
                            width: _containerWidth,
                            height: _containerHeight,
                            color: Colors.black,
                            child: Center(
                              child: state is LoadedOverlayFeatureState &&
                                      currentState.playerController != null
                                  ? SizedBox.expand(
                                      child: FittedBox(
                                        fit: currentState.playerController!.value.size.width >=
                                                currentState.playerController!.value.size.height
                                            ? BoxFit.cover
                                            : BoxFit.scaleDown,
                                        child: SizedBox(
                                          width: currentState.playerController!.value.size.width,
                                          height: currentState.playerController!.value.size.height,
                                          child: VideoPlayer(
                                            currentState.playerController!,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        if (state is LoadedOverlayFeatureState &&
                            currentState.playerController != null &&
                            currentState.showButtons)
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: () {
                                context
                                    .read<TopOverlayFeatureBloc>()
                                    .add(ShowAndHideButtonsOnClickEvent());
                              },
                              child: Material(
                                color: Colors.black.withValues(alpha: 0.5),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () {
                                          context.read<TopOverlayFeatureBloc>().add(
                                                PlayAndPauseVideoEvent(),
                                              );
                                        },
                                        child: Center(
                                          child: Icon(
                                            currentState.isPlaying ? Icons.stop : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (state is LoadedOverlayFeatureState &&
                            currentState.playerController != null &&
                            currentState.showButtons)
                          Positioned(
                            top: 3,
                            right: 3,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
