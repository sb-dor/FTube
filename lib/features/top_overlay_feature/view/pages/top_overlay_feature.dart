import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_bloc.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_events.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_states.dart';
import 'package:youtube/features/top_overlay_feature/view/overlay_opener/top_overlay_logic.dart';

class TopOverlayFeature extends StatefulWidget {
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
  State<TopOverlayFeature> createState() => _TopOverlayFeatureState();
}

class _TopOverlayFeatureState extends State<TopOverlayFeature> {
  // late StreamSubscription _subscription;
  late final TopOverlayFeatureBloc _topOverlayFeatureBloc;

  Offset offset = const Offset(20, 40);

  @override
  void dispose() {
    // _subscription.cancel();
    _topOverlayFeatureBloc.add(DisposeOverlayVideoController());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _topOverlayFeatureBloc = BlocProvider.of<TopOverlayFeatureBloc>(context);
    // _subscription = FlutterOverlayWindow.overlayListener.listen((event) {
    context.read<TopOverlayFeatureBloc>().add(ConvertToLoadingState());
    //   debugPrint("Current Event: $event | type: ${event.runtimeType}");
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
              offset += details.delta;
              widget.overlayEntry.markNeedsBuild();
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
                        Container(
                          width: 250,
                          height: 150,
                          color: Colors.black,
                          child: Center(
                            child: state is LoadedOverlayFeatureState &&
                                    currentState.playerController != null
                                ? GestureDetector(
                                    onTap: () {},
                                    child: SizedBox.expand(
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
                        Positioned(
                          top: 3,
                          right: 3,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
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
                        // if (state is LoadedOverlayFeatureState &&
                        //     currentState.playerController != null &&
                        //     !(currentState.playerController?.value.isPlaying ?? false))
                          Positioned(
                            child: Material(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(50),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {},
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                  ),
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
